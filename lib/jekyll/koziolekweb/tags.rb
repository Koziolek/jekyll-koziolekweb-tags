# frozen_string_literal: true

require "liquid"
require "jekyll"
require "jekyll/converters/markdown"
require "shellwords"
require "yaml"
require "cgi"
require_relative "tags/version"

module Koziolekweb
  module Tags
    class Listing < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        matched = markup.strip.match(/\A(\w+)\s+["'](.+?)["']\z/)
        if matched
          @lang = matched[1]
          @title = matched[2]
        else
          raise Liquid::SyntaxError, <<~ERROR.strip
            Invalid parameters for listing. Usage:
              {% listing lang 'title' %}
              code goes here
              {% endlisting %}
            Got:
              #{markup}
          ERROR
        end
      end

      def render(context)
        current_file = context.registers.dig(:page, "path") || "__global__"
        context.registers[:listing_count] ||= {}
        context.registers[:listing_count][current_file] ||= 0
        listing_number = (context.registers[:listing_count][current_file] += 1)
        content = super.chomp

        markdown_converter = context.registers[:site].find_converter_instance(Jekyll::Converters::Markdown)
        title_html = markdown_converter.convert(@title).strip.sub(%r{\A<p>(.*)</p>\z}, '\1')
        markdown_code = "```#{@lang}\n#{content}\n```"
        code_html = markdown_converter.convert(markdown_code).strip

        <<~HTML
            <p class='listing'> Listing #{listing_number}. #{title_html}</p>
            #{code_html}
          HTML
      end
    end

    class Offtop < Liquid::Block
      VALID_DIRECTIONS = %w[right left].freeze

      def initialize(tag_name, markup, tokens)
        super
        @params = parse_params(markup)

        @direction = @params.fetch('direction', 'right').strip

        unless self.class::VALID_DIRECTIONS.include?(@direction)
          raise ArgumentError, "Invalid direction '#{@direction}'. Allowed values are: #{VALID_DIRECTIONS.join(', ')}"
        end
      end

      def render(context)
        content = super
        "<aside class=\"offtopic f-#{@direction}\">#{content}</aside>"
      end

      private

      def parse_params(text)
        params = {}
        text.scan(/(\w+)\s*:\s*("[^"]*"|\S+)/).each do |key, val|
          val = val.delete_prefix('"').delete_suffix('"') if val.start_with?('"')
          params[key] = val
        end
        params
      end
    end

    class YtVideo < Liquid::Tag
      def initialize(tag_name, video_id, tokens)
        super
        @video_id = video_id.strip

        if @video_id.empty? || !valid_video_id?(@video_id)
          raise Liquid::SyntaxError, "Invalid video ID: #{@video_id.inspect}"
        end

      end

      def render(_context)
        <<~HTML
          <div class="video">
            <iframe title="Youtube Video" src="https://www.youtube-nocookie.com/embed/#{@video_id}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
          </div>
        HTML
      end

      private

      def valid_video_id?(video_id)
        video_id.match?(/\A[\w-]{11}\z/)
      end

    end

    class Book < Liquid::Tag
      MIN_ARGS = 5

      def initialize(tag_name, markup, tokens)
        super

        args = Shellwords.split(markup)
        raise Liquid::SyntaxError, "Invalid usage" if args.size < self::MIN_ARGS

        @title, @author, @year, @isbn, @cover_url = args[0..4].map { _1.delete('"') }

        unless @year.match?(/\A\d{4}\z/)
          raise Liquid::SyntaxError, "Invalid publication year: #{@year.inspect}"
        end

        lang_arg = args.find { |s| s.start_with?("lang:") }
        @lang = lang_arg&.split(":", 2)&.last || "en"

        unless @lang.match?(/\A[a-z]{2}\z/i)
          raise Liquid::SyntaxError, "Invalid language code: #{@lang.inspect}"
        end
        # Inicjalizacja LanguageManager
        lang_data_path = File.join(Dir.pwd, '_data', 'lang') # Katalog z plikami językowymi
        config_path = File.join(Dir.pwd, '_config.yml') # Ścieżka do pliku `_config.yml`
        @language_manager = Koziolekweb::LanguageSupport::LanguageManager.new(config_path, lang_data_path)
      end

      def render(_context)
        title_html  = CGI.escapeHTML(@title)
        author_html = CGI.escapeHTML(@author)
        year_html   = CGI.escapeHTML(@year)
        isbn_html   = CGI.escapeHTML(@isbn.to_s)
        label_title = @language_manager.translate('title', @lang, 'Tytuł')
        label_author = @language_manager.translate('author', @lang, 'Autor')
        label_year = @language_manager.translate('year', @lang, 'Rok')
        label_isbn = @language_manager.translate('isbn', @lang, 'ISBN')
        cover_alt = @language_manager.translate('cover_alt', @lang, 'Okładka książki %{title} autorstwa %{author}')
                                     .gsub('%{title}', @title)
                                     .gsub('%{author}', @author)

        <<~HTML
          <div class="book">
            <img src="#{@cover_url}" alt="#{cover_alt}" title="#{@title}" class="cover" />
            <div class="book_desc">
              <ul>
                <li><span>#{label_title}: </span>#{title_html}</li>
                <li><span>#{label_author}: </span>#{author_html}</li>
                <li><span>#{label_year}: </span>#{year_html}</li>
                #{@isbn.nil? ? "" : "<li><span>#{label_isbn}: </span>#{isbn_html}</li>"}
              </ul>
            </div>
          </div>
        HTML
      end
    end
  end

  module LanguageSupport
    class LanguageManager
      attr_reader :default_language
      def initialize(config_path, lang_data_path)
        @dictionary_cache = {}
        @config_path = config_path
        @lang_data_path = lang_data_path
        @default_language = load_default_language
      end

      # Pobiera tłumaczenie dla danego klucza
      def translate(key, lang = nil, default_value = nil)
        lang ||= default_language
        load_dictionary(lang)[key] || default_value
      end

      private

      # Wczytanie domyślnego języka z pliku `_config.yml`
      def load_default_language
        if File.exist?(@config_path)
          config = YAML.load_file(@config_path)
          config['lang'] || 'en'
        else
          'en'
        end
      end

      # Wczytuje słownik dla danego języka
      def load_dictionary(lang)
        @dictionary_cache[lang] ||=
          begin
            dictionary_path = File.join(@lang_data_path, "#{lang}.yml")
            if File.exist?(dictionary_path)
              YAML.safe_load(File.read(dictionary_path), aliases: true)
            else
              {}
            end
          end
      end
    end

  end
end

%w[listing offtop yt_video book].each do |tag|
  class_name = tag.split('_').map(&:capitalize).join
  begin
    klass = Koziolekweb::Tags.const_get(class_name)
    Liquid::Template.register_tag(tag, klass)
  rescue NameError
    warn "[WARN] Tag '#{tag}' not registered: Koziolekweb::Tags::#{class_name} not defined"
  end
end