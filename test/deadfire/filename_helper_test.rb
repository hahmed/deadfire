require "test_helper"

class FilenameHelperTest < Minitest::Test
  def test_parses_import_path_with_double_quotes_correctly
    assert_equal "something", Deadfire::FilenameHelper.normalize_path("@import \"something\"")
  end

  def test_parses_import_path_with_single_quotes_correctly
    assert_equal "something", Deadfire::FilenameHelper.normalize_path("@import \'something\'")
  end

  def test_parses_import_path_with_semicolons_correctly
    assert_equal "something", Deadfire::FilenameHelper.normalize_path("@import \"something\";")
  end

  def test_parses_import_path_with_dirname_correctly
    assert_equal "admin/test3.css", Deadfire::FilenameHelper.normalize_path("@import \"admin/test3.css\";")
  end
end
