# frozen_string_literal: true

require "minitest/autorun"
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "jekyll/koziolekweb/tags"

class TestOfftop < Minitest::Test
  def setup
    @context = Liquid::Context.new({}, {}, { registers: {} })
  end

  def render_tag(markup, content = "Offtopic content")
    template_str = "{% offtop #{markup} %}#{content}{% endofftop %}"
    Liquid::Template.parse(template_str).render!(@context)
  end

  def test_default_direction
    output = render_tag('text:"hello"')
    assert_includes output, 'class="offtopic f-right"'
    assert_includes output, "Offtopic content"
  end

  def test_left_direction
    output = render_tag('text:"hello" direction:left')
    assert_includes output, 'class="offtopic f-left"'
  end

  def test_invalid_direction_raises_error
    assert_raises(ArgumentError) do
      render_tag('text:"hello" direction:up')
    end
  end

  def test_text_param_parsed
    output = render_tag('text:"coś"')
    assert_includes output, "Offtopic content"
  end

  def test_generates_aside_element
    output = render_tag('direction:left')
    assert_match %r{<aside class="offtopic f-left">.*</aside>}m, output
  end

  def test_with_irregular_spacing
    output = render_tag('   direction:  left   ')
    assert_includes output, 'class="offtopic f-left"'
  end

  def test_without_any_params
    output = render_tag('')
    assert_includes output, 'class="offtopic f-right"'
  end

  def test_ignores_unknown_params
    output = render_tag('direction:right foo:"bar"')
    assert_includes output, 'class="offtopic f-right"'
  end
end
