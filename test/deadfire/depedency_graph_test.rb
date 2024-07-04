require "test_helper"

class DependencyGraphTest < Minitest::Test
  def after
    Deadfire::DependencyGraph.reset
  end
  
  def test_the_depedency_graph_is_empty_when_no_imports
    Deadfire.parse("body {\n  color: red;\n}\n")
    assert_empty Deadfire::DependencyGraph.dependencies
  end

  def test_the_depedency_graph_is_empty_when_import_files_are_not_found
    Deadfire.parse("body {\n  @import 'application.css';\n}\n")
    assert_empty Deadfire::DependencyGraph.dependencies
  end

  def test_the_dependency_graph_has_one_dependency
    Deadfire.parse("body {\n  @import 'application.css';\n}\n")
    assert_equal 1, Deadfire::DependencyGraph.dependencies.count
    assert_equal ["application.css"], Deadfire::DependencyGraph.dependencies.keys
  end

  def test_the_dependency_graph_has_multiple_dependencies
    Deadfire.parse("body {\n  @import 'application.css';\n  @import 'reset.css';\n}\n")
    assert_equal 2, Deadfire::DependencyGraph.dependencies.count
    assert_equal ["root", "reset.css"], Deadfire::DependencyGraph.dependencies.keys
  end

  def test_the_dependency_graph_has_nested_depedency
    true
  end
end