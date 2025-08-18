require "minitest/autorun"

require_relative "../../lib/middleman-inline_svg/inline_svg"

class TestInlineSVG < Minitest::Test
  def test_it_adds_a_title
    new_svg = InlineSVG.new(
      File.open("test/fixtures/circle.svg"),
      title: "Circle",
    ).to_html

    expected_svg = <<~SVG
      <svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"64px\" height=\"64px\" viewBox=\"0 0 64 64\" version=\"1.1\"><title>Circle</title>
        <circle id="Oval" fill="#000000" cx="32" cy="32" r="30"></circle>
      </svg>
    SVG

    assert_equal new_svg, expected_svg
  end

  def test_it_adds_a_class
    new_svg = InlineSVG.new(
      File.open("test/fixtures/circle.svg"),
      class: "circle",
    ).to_html

    expected_svg = <<~SVG
      <svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"64px\" height=\"64px\" viewBox=\"0 0 64 64\" version=\"1.1\" class="circle">
        <circle id="Oval" fill="#000000" cx="32" cy="32" r="30"></circle>
      </svg>
    SVG

    assert_equal new_svg, expected_svg
  end

  def test_it_adds_multiple_attributes
    new_svg = InlineSVG.new(
      File.open("test/fixtures/circle.svg"),
      class: "circle",
      role: "img",
      id: "circle",
    ).to_html

    expected_svg = <<~SVG
      <svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"64px\" height=\"64px\" viewBox=\"0 0 64 64\" version=\"1.1\" class="circle" role="img" id="circle">
        <circle id="Oval" fill="#000000" cx="32" cy="32" r="30"></circle>
      </svg>
    SVG

    assert_equal new_svg, expected_svg
  end

  def test_it_transforms_attribute_names
    new_svg = InlineSVG.new(
      File.open("test/fixtures/circle.svg"),
      aria_hidden: true,
    ).to_html

    expected_svg = <<~SVG
      <svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"64px\" height=\"64px\" viewBox=\"0 0 64 64\" version=\"1.1\" aria-hidden="true">
        <circle id="Oval" fill="#000000" cx="32" cy="32" r="30"></circle>
      </svg>
    SVG

    assert_equal new_svg, expected_svg
  end
end
