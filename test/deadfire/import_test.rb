require "test_helper"

class ImportTest < Minitest::Test
  def setup
    Deadfire.configuration.root_path = fixtures_path
  end

  def teardown
    Deadfire.reset
  end

  def test_raises_error_when_invalid_import_location
    assert_raises(Deadfire::ImportException) do
      Deadfire::Import.resolve_import_path("randomness/test_1", 0)
    end
  end

  def test_basic_import
    import_path = Deadfire::Import.resolve_import_path("test_1", 0)
    assert_equal <<~CSS.strip, Deadfire::Import.resolve(import_path)
      .test_css_1 {
        padding: 1rem;
      }
    CSS
  end

  def test_import_with_extension
    import_path = Deadfire::Import.resolve_import_path("test_1.css", 0)
    assert_equal <<~CSS.strip, Deadfire::Import.resolve(import_path)
      .test_css_1 {
        padding: 1rem;
      }
    CSS
  end

  def test_import_in_admin_directory
    import_path = Deadfire::Import.resolve_import_path("admin/test_3.css", 0)
    output = Deadfire::Import.resolve(import_path)
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

  def test_parses_import_path_with_semicolons_correctly
    assert_equal "something", Deadfire::Import.parse_import_path("@import \"something\";")
  end

  def test_parses_import_path_with_dirname_correctly
    assert_equal "admin/test3.css", Deadfire::Import.parse_import_path("@import \"admin/test3.css\";")
  end
end