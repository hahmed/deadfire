require "test_helper"

class AssetRegistryTest < Minitest::Test
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

  def test_asterix_loads_all_mixins
    @loader.register_path("*", "test_1.css")
    assert_includes @loader.mixins_for("*"), asset_path("test_1.css")
  end

  def test_path_with_scope_loads_no_mixins
    @loader.register_path("admin", "test_1.css")
    assert_empty @loader.mixins_for("test.css")
  end

  def test_path_with_scope_loads_mixin
    @loader.register_path("admin/", "test_1.css")
    puts @loader.settings.inspect
    puts @loader.mixins_for("admin/something.css").inspect
    assert_includes @loader.mixins_for("admin/something.css"), asset_path("test_1.css")
  end

  def test_path_includes_scope_with_all_subfolders
    @loader.register_path("admin/*", "test_1.css")
    assert_includes @loader.mixins_for("admin/test.css"), asset_path("test_1.css")
  end

  def test_scope_path_loads_scoped_mixins_only
    @loader.register_path("admin/*", "test_1.css")
    @loader.register_path("app", "vendor")
    assert_includes @loader.mixins_for("admin/some_file.css"), asset_path("test_1.css")
  end

  private

  def asset_path(filename)
    File.join(fixtures_path, filename)
  end

  def application_mixins
    @loader.mixins_for("application")
  end
end