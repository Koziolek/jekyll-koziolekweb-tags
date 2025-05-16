# frozen_string_literal: true

require "minitest/autorun"
require "jekyll"
require "jekyll/koziolekweb/tags"
require "fileutils"
require "tmpdir"

class TestListing < Minitest::Test
  def setup
    @tmp_dir = Dir.mktmpdir("jekyll-test")
    config = Jekyll::Configuration::DEFAULTS.merge({
                                                     "source" => @tmp_dir,
                                                     "destination" => File.join(@tmp_dir, "_site"),
                                                     "quiet" => true,
                                                     "markdown" => "kramdown",
                                                     "kramdown" => { "input" => "GFM" }
                                                   })

    @site = Jekyll::Site.new(Jekyll.configuration(config))
    @context = Liquid::Context.new({}, {}, {
        site: @site,
        page: { "path" => "dummy.md" },
        listing_count: {}
    })
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir) if @tmp_dir && Dir.exist?(@tmp_dir)
  end

  def render_tag(lang: "ruby", title: "Example Title", content: "puts 'Hi'")
    template_str = "{% listing #{lang} \"#{title}\" %}#{content}{% endlisting %}"
    Liquid::Template.parse(template_str).render(@context)
  end

  def test_valid_markup
    output = render_tag
    assert_includes output, "Listing 1"
    assert_includes output, "Example Title"
    assert_includes output, "class=\"language-ruby "
    assert_includes output, "puts"
    assert_includes output, "'Hi'"
  end

  def test_listing_increments
    render_tag(title: "First listing")
    output = render_tag(title: "Second listing")
    assert_includes output, "Listing 2"
  end

  def test_invalid_markup_raises
    err = assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse("{% listing %}code{% endlisting %}").render!(@context)
    end
    assert_match(/Invalid parameters/, err.message)
  end

  def test_allows_markdown_in_title
    output = render_tag(title: "**Bold** _Title_")
    assert_includes output, "<strong>Bold</strong> <em>Title</em>"
  end
end
