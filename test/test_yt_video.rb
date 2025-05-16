require 'minitest/autorun'
require "jekyll/koziolekweb/tags"


class TestYtVideo < Minitest::Test
  def render_tag(video_id)
    template = Liquid::Template.parse("{% yt_video #{video_id} %}")
    template.render
  end

  def test_valid_video_id
    video_id = "dQw4w9WgXcQ"
    result = render_tag(video_id)

    expected = <<~HTML
      <div class="video">
        <iframe title="Youtube Video" src="https://www.youtube-nocookie.com/embed/#{video_id}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
      </div>
    HTML

    assert_equal expected.strip, result.strip
  end

  def test_video_id_with_spaces
    video_id = " dQw4w9WgXcQ " # ID z białymi znakami
    result = render_tag(video_id)

    expected = <<~HTML
      <div class="video">
        <iframe title="Youtube Video" src="https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
      </div>
    HTML

    assert_equal expected.strip, result.strip
  end

  def test_empty_video_id
    video_id = "" # Pusty ID
    assert_raises(Liquid::SyntaxError) do
      render_tag(video_id)
    end
  end

  def test_blank_video_id
    video_id = "   " # Tylko białe znaki
    assert_raises(Liquid::SyntaxError) do
      render_tag(video_id)
    end
  end

  def test_invalid_characters_in_video_id
    video_id = "dQw4w9WgXcQ<script>" # Niedozwolone znaki
    assert_raises(Liquid::SyntaxError) do
      render_tag(video_id)
    end
  end

  def test_too_long_video_id
    video_id = "dQw4w9WgXcQX" # 12 znaków
    assert_raises(Liquid::SyntaxError) do
      render_tag(video_id)
    end
  end

  def test_too_short_video_id
    video_id = "abc123" # za krótki
    assert_raises(Liquid::SyntaxError) do
      render_tag(video_id)
    end
  end

  def test_valid_characters_with_dashes_and_underscores
    video_id = "abc_def-123"
    result = render_tag(video_id)

    expected = <<~HTML
    <div class="video">
      <iframe title="Youtube Video" src="https://www.youtube-nocookie.com/embed/#{video_id}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
    </div>
  HTML

    assert_equal expected.strip, result.strip
  end
end
