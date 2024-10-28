require "test_helper"

class AsssetRegistryTest < Minitest::Test
  def setup
    Deadfire.configure { |config| config.root_path = fixtures_path }
    @loader = Deadfire.configuration.asset_registry
  end

  def teardown
    Deadfire.reset
  end

  def test_register_path_successfully
    @loader.register_path("application", "test_1")
    assert_includes application_mixins, asset_path("test_1.css")
  end

  def test_register_multiple_paths_successfully
    @loader.register_path("application", "test_1", "vendor2")
    assert_includes application_mixins, asset_path("test_1.css")
    assert_includes application_mixins, asset_path("vendor2.css")
  end

  def test_register_custom_path_succesfully
    @loader.register_path("application", "admin/test_3")
    assert_includes application_mixins, asset_path("admin/test_3.css")
  end

  private

  def asset_path(filename)
    File.join(fixtures_path, filename)
  end

  def application_mixins
    @loader.mixins_for("application")
  end
end