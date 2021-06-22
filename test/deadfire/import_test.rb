require "test_helper"

class ImportTest < Minitest::Test
  def setup
    Deadfire.configuration.root_path = fixtures_path
  end

  def teardown
    Deadfire.reset
  end

  def test_raises_error_when_invalid_import_location
    importer = Deadfire::Import.new("randomness/test_1", 0)
    assert_raises(Deadfire::FileNotFoundError) do
      importer.resolve
    end
  end

  def test_basic_import
    importer = Deadfire::Import.new("test_1", 0)
    output = importer.resolve
    assert_equal <<~CSS.strip, output
      .test_css_1 {
        padding: 1rem;
      }
    CSS
  end

  def test_import_with_extension
    importer = Deadfire::Import.new("test_2.css", 0)
    output = importer.resolve
    assert_equal <<~CSS.strip, output
      .test_css_2 {
        padding: 2rem;
      }
    CSS
  end

  def test_import_in_admin_directory
    importer = Deadfire::Import.new("admin/test_3.css", 0)
    output = importer.resolve
    assert_equal <<~CSS.strip, output
      .test_css_3 {
        padding: 3rem;
      }
    CSS
  end

  def test_parses_import_path_with_double_quotes_correctly
    assert_equal "something", Deadfire::Import.parse_import_path("@import \"something\"")
  end

  def test_parses_import_path_with_single_quotes_correctly
    assert_equal "something", Deadfire::Import.parse_import_path("@import \'something\'")
  end
end