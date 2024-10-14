# frozen_string_literal: true

require_relative "tags/version"

module Koziolekweb
  module Tags
    class Listing < Liquid::Block
      @@file_state = {}

      def initialize(tag_name, markup, tokens)
        super

        matched = /(\w+)\s+["'](.*?)["']/.match(markup)

        if matched
          @lang = matched[1]
          @title = matched[2]
        else
          raise SyntaxError.new("
            Invalid parameters for listing. Usage:
                {% listing lang 'title' %}
                code goes here
                {% endlisting %}
            got
            #{markup}")
        end
      end

      def render(context)
        current_file = context.registers[:page]["path"]
        @@file_state[current_file] ||= 0
        @@file_state[current_file] += 1
        content = super
        content_with_code_fence = "```#{@lang} #{content}```"

        "<p class='listing'> Listing #{@@file_state[current_file]}. #{@title}</p>#{content_with_code_fence}"
      end
    end

    class Offtop < Liquid::Block

      def initialize(tag_name, markup, tokens)
        super
        @direction = markup
      end

      def render(context)
        content = super
        "<aside class=\"offtopic f-#{@direction}\">#{content}</aside>"
      end
    end

    class YtVideo < Liquid::Tag
      def initialize(tag_name, video_id, tokens)
        super
        @video_id = video_id.strip
      end

      def render(_context)
        <<~HTML
        <div class="video">
          <iframe src="https://www.youtube-nocookie.com/embed/#{@video_id}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
        </div>
      HTML
      end
    end
  end
end

Liquid::Template.register_tag('listing', Koziolekweb::Tags::Listing)
Liquid::Template.register_tag('offtop', Koziolekweb::Tags::Offtop)
Liquid::Template.register_tag('yt_video', Koziolekweb::Tags::YtVideo)