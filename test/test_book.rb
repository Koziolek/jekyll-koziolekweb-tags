# frozen_string_literal: true

require "minitest/autorun"
require "liquid"
require "cgi"
require "shellwords"
require_relative "../lib/jekyll/koziolekweb/tags"

module Koziolekweb
  module LanguageSupport
    class DummyLanguageManager
      def translate(key, lang = nil, default_value = nil)
        {
          "title" => "Tytuł",
          "author" => "Autor",
          "year" => "Rok",
          "isbn" => "ISBN",
          "cover_alt" => "Okładka książki %{title} autorstwa %{author}"
        }[key] || default_value
      end
    end
  end

  module Tags
    class TestBookTag < Liquid::Tag
      def initialize(tag_name, markup, tokens)
        args = Shellwords.split(markup)
        raise Liquid::SyntaxError, "Invalid usage" if args.size < 5

        @title, @author, @year, @isbn, @cover_url = args[0..4].map { _1.delete('"') }

        raise Liquid::SyntaxError, "Invalid publication year: #{@year.inspect}" unless @year.match?(/\A\d{4}\z/)

        lang_arg = args.find { |s| s.start_with?("lang:") }
        @lang = lang_arg&.split(":", 2)&.last || "en"

        unless @lang.match?(/\A[a-z]{2}\z/i)
          raise Liquid::SyntaxError, "Invalid language code: #{@lang.inspect}"
        end

        @language_manager = Koziolekweb::LanguageSupport::DummyLanguageManager.new
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
end

Liquid::Template.register_tag("book", Koziolekweb::Tags::TestBookTag)

class TestBook < Minitest::Test
  def render_tag(markup)
    template = Liquid::Template.parse("{% book #{markup} %}")
    template.render
  end

  def test_valid_markup
    markup = "\"Tytuł Książki\" \"Autor Nazwisko\" 2023 \"123-456-789\" \"/path/to/cover.jpg\" lang:pl"
    output = render_tag(markup)

    assert_includes output, "Tytuł Książki"
    assert_includes output, "Autor Nazwisko"
    assert_includes output, "2023"
    assert_includes output, "123-456-789"
    assert_includes output, "/path/to/cover.jpg"
    assert_includes output, "Okładka książki Tytuł Książki autorstwa Autor Nazwisko"
  end

  def test_missing_arguments
    markup = "\"Tytuł\" \"Autor\" 2023"
    assert_raises(Liquid::SyntaxError) { render_tag(markup) }
  end

  def test_invalid_year
    markup = "\"Tytuł\" \"Autor\" abcd \"123-456\" \"/cover.jpg\" lang:pl"
    assert_raises(Liquid::SyntaxError) { render_tag(markup) }
  end

  def test_invalid_lang
    markup = "\"Tytuł\" \"Autor\" 2023 \"123-456\" \"/cover.jpg\" lang:xyz"
    assert_raises(Liquid::SyntaxError) { render_tag(markup) }
  end

  def test_escaped_html
    markup = "\"<Tytuł>\" \"<Autor>\" 2023 \"123\" \"/cover.jpg\" lang:pl"
    output = render_tag(markup)

    assert_includes output, "&lt;Tytuł&gt;"
    assert_includes output, "&lt;Autor&gt;"
  end
end