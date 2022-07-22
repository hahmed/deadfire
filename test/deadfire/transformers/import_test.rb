require "test_helper"

module Transformers
  class ImportTest < Minitest::Test
    def setup
      Deadfire.configuration.root_path = fixtures_path
    end
  
    def teardown
      Deadfire.reset
    end

    def test_parses_import_path_with_double_quotes_correctly
      assert_equal "something", Deadfire::Transformers::Import.normalize_import_path("@import \"something\"")
    end
  
    def test_parses_import_path_with_single_quotes_correctly
      assert_equal "something", Deadfire::Transformers::Import.normalize_import_path("@import \'something\'")
    end
  
    def test_parses_import_path_with_semicolons_correctly
      assert_equal "something", Deadfire::Transformers::Import.normalize_import_path("@import \"something\";")
    end
  
    def test_parses_import_path_with_dirname_correctly
      assert_equal "admin/test3.css", Deadfire::Transformers::Import.normalize_import_path("@import \"admin/test3.css\";")
    end

    def test_raises_error_when_invalid_import_location
      assert_raises(Deadfire::ImportException) do
        css_import_content("randomness/test_1")
      end
    end
  
    def test_basic_import
      assert_equal <<~CSS.strip, css_import_content("test_1")
        .test_css_1 {
          padding: 1rem;
        }
      CSS
    end
  
    def test_import_with_extension
      assert_equal <<~CSS.strip, css_import_content("test_1.css")
        .test_css_1 {
          padding: 1rem;
        }
      CSS
    end
  
    def test_import_in_admin_directory
      assert_equal <<~CSS.strip, css_import_content("admin/test_3.css")
        .test_css_3 {
          padding: 3rem;
        }
      CSS
    end

    private

    def css_import_content(path)
      normalized_path = Deadfire::Transformers::Import.resolve_import_path(path)
      Deadfire::Transformers::Import.parse_import_path("@import \"#{normalized_path}\"")
    end
  end
end