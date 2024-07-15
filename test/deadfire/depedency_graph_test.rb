require "test_helper"

class ImportDependencyTest < Minitest::Test
  def setup
    Deadfire.configuration.compressed = true
    Deadfire.configuration.root_path = fixtures_path
    Deadfire::Interpreter.cached_apply_rules = {}
    Deadfire::ImportDependency.reset
  end

  def teardown
    Deadfire.reset
  end
  
  def test_import_depedency_is_empty_when_no_imports
    Deadfire.parse("body {\n  color: red;\n}\n")
    assert_empty Deadfire::ImportDependency.files
  end

  def test_import_depedency_is_empty_when_import_files_are_not_found
    Deadfire.parse("body {\n  @import 'random.css';\n}\n")
    assert_empty Deadfire::ImportDependency.files
  end

  def test_import_dependency_has_one_file
    Deadfire.parse(css_import_from_path("application.css"))
    assert_equal 2, Deadfire::ImportDependency.files.count
    assert_equal [import_path("application.css")], Deadfire::ImportDependency.fetch("root")
  end

  def test_import_dependency_has_multiple_files
    Deadfire.parse(css_import_from_path("multiple_imports.css"))
    assert_equal 2, Deadfire::ImportDependency.files.count
    assert_equal [import_path("multiple_imports.css")], Deadfire::ImportDependency.fetch("root")
    assert_equal [import_path("test_1.css"), import_path("admin/test_3.css")], Deadfire::ImportDependency.fetch(import_path("multiple_imports.css"))
  end

  private

  def import_path(import)
    File.expand_path(File.join(fixtures_path, import))
  end
end