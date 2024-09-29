require "test_helper"

class AsssetLoaderTest < Minitest::Test
  def setup
    @loader = Deadfire::AssetLoader.new
  end

  def test_register_path_successfully
    @loader.register_path(:default, "admin")
    assert_equal ["admin"], @loader.settings["default"]
  end

  def test_register_multiple_paths_successfully
    @loader.register_path(:default, "admin", "dashboard")
    assert_equal ["admin", "dashboard"], @loader.settings["default"]
  end

  def test_register_custom_path_succesfully
    @loader.register_path("admin/dashboard", "admin")
    assert_equal ["admin"], @loader.settings["admin/dashboard"]
  end
end