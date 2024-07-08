require "test_helper"

class DependencyGraphTest < Minitest::Test
  def setup
    Deadfire.configuration.compressed = true
    Deadfire.configuration.root_path = fixtures_path
    Deadfire::Interpreter.cached_apply_rules = {}
  end

  def teardown
    Deadfire::DependencyGraph.reset
  end
  
  def test_the_depedency_graph_is_empty_when_no_imports
    Deadfire.parse("body {\n  color: red;\n}\n")
    assert_empty Deadfire::DependencyGraph.dependencies
  end

  def test_the_depedency_graph_is_empty_when_import_files_are_not_found
    Deadfire.parse("body {\n  @import 'random.css';\n}\n")
    assert_empty Deadfire::DependencyGraph.dependencies
  end

  def test_the_dependency_graph_has_one_dependency
    Deadfire.parse(css_import_from_path("application.css"))
    assert_equal 2, Deadfire::DependencyGraph.dependencies.count
    assert_equal [import_path("application.css")], Deadfire::DependencyGraph.dependencies["root"]
  end

  def test_the_dependency_graph_has_multiple_dependencies
    Deadfire.parse(css_import_from_path("multiple_imports.css"))
    assert_equal 2, Deadfire::DependencyGraph.dependencies.count
    assert_equal [import_path("multiple_imports.css")], Deadfire::DependencyGraph.dependencies["root"]
    assert_equal [import_path("test_1.css"), import_path("admin/test_3.css")], Deadfire::DependencyGraph.dependencies[import_path("multiple_imports.css")]
  end

  private

  def import_path(import)
    File.expand_path(File.join(fixtures_path, import))
  end
end