require_relative "../test_helper"
# require "strscan"

class NestTest < Minitest::Test
  def test_nest_selector_used_on_its_own
    output = <<~CSS
    .foo {
      color: blue;
    }
    .foo > .bar { color: red; }
    CSS

    assert_includes output, parse_input(<<~INPUT)
    .foo {
      color: blue;
      & > .bar { color: red; }
    }
    INPUT
  end

  def test_nest_in_compound_selector
    output = <<~CSS
    .foo {
      color: blue;
    }
    .foo.bar { color: red; }
    CSS

    assert_includes output, parse_input(<<~INPUT)
    .foo {
      color: blue;
      &.bar { color: red; }
    }
    INPUT
  end

  def test_multiple_selectors_unfold_when_correct_starting_selector_is_used
    skip

    output = <<~CSS
    .foo {
      color: blue;
    }
    .foo.bar { color: red; }
    CSS

    assert_equal output, parse_input(<<~INPUT)
    .foo, .bar {
      .foo, .bar { color: blue; }
      :is(.foo, .bar) + .baz,
      :is(.foo, .bar).qux { color: red; }
    }
    INPUT
  end

  def test_selectors_can_be_used_multiple_times_in_single_selector
    output = <<~CSS
    .foo {
      color: blue;
    }
    .foo .bar .foo .baz .foo .qux { color: red; }
    CSS

    assert_includes output, parse_input(<<~INPUT)
    .foo {
      color: blue;
      & .bar & .baz & .qux { color: red; }
    }
    INPUT
  end

  def test_complete_nesting_unfolds_correctly
    output = <<~CSS
    table.colortable {
    }
    table.colortable th {
      text-align:center;
      background:black;
      color:white;
    }
    table.colortable td {
      text-align:center;
    }
    table.colortable td.c {
      text-transform:uppercase;
    }
    table.colortable td:first-child, table.colortable td:first-child+td {
      border:1px solid black;
    }
    CSS

    assert_includes parse_input(<<~INPUT), output
    table.colortable {
      & th {
        text-align:center;
        background:black;
        color:white;
      }
      & td {
        text-align:center;
        &.c { text-transform:uppercase }
        &:first-child, &:first-child + td { border:1px solid black }
      }
    }
    INPUT
  end

  private

    def parse_input(input)
      buffer = StringIO.new(input)
      output = []

      while ! buffer.eof?
        current_line = buffer.gets

        if Deadfire::Nest.match?(current_line)
          Deadfire::Nest.resolve(buffer, output, current_line, buffer.lineno)
        else
          output << current_line
        end
      end

      output.flatten.join
    end
end