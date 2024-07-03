require "test_helper"

class DependencyGraphTest < Minitest::Test
  def test_the_depedency_are_empty_when_no_imports
    Deadfire.parse("body {\n  color: red;\n}\n")
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
    assert_equal ["application.css", "reset.css"], Deadfire::DependencyGraph.dependencies.keys
  end

  def test_the_dependency_graph_has_nested_depedency
    true
  end
end