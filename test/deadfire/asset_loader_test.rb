require "test_helper"

class AssetLoaderTest < Minitest::Test
  def setup
    Dir.mkdir(tmp_path) unless Dir.exist?(tmp_path)
  end

  def teardown
    clear_cache
    Deadfire.reset
  end

  def test_valid_file_path_loads_mixin
    default_config
    loader = Deadfire::AssetLoader.new("mixin.css")
    assert_equal 3, loader.preload.size
  end

  def test_invalid_file_still_loads_root_mixin
    default_config
    loader = Deadfire::AssetLoader.new("invalid.css")
    assert_equal 0, loader.preload.size
  end

  def test_mixin_not_loaded_when_root_file_not_set
    default_config
    Deadfire.configuration.asset_registry.settings.clear
    loader = Deadfire::AssetLoader.new("mixin.css")
    assert_equal 0, loader.preload.size
  end

  def test_mixin_is_loaded_from_path_folder_and_root_folder
    default_config
    Deadfire.configuration.asset_registry.register_path("mixin.css", "admin/test_3.css")

    loader = Deadfire::AssetLoader.new("mixin.css")
    assert_equal 4, loader.preload.size
  end

  def test_mixin_is_overrided_successfully_and_new_value_is_returned
    default_config
    Deadfire.configuration.asset_registry.register_path("mixin.css", "vendor_overrides.css")

    loader = Deadfire::AssetLoader.new("mixin.css")
    mixins = loader.preload
    assert_equal 3, mixins.size
    assert_equal "{\n  font-weight: bolder;\n}", mixins[".font-bold"].declarations.map(&:lexeme).join
  end

  def test_mixin_loads_latest_version_when_cache_is_invalidated
    Deadfire.configuration.root_path = tmp_path
    tmp_mixin_file = File.join(tmp_path, "vendor.css")
    FileUtils.cp(File.join(fixtures_path, "vendor.css"), tmp_mixin_file)

    Deadfire.configuration.asset_registry.register_path("mixin.css", "vendor.css")

    loader = Deadfire::AssetLoader.new("mixin.css")
    assert_equal 3, loader.preload.size

    # update content for vendor file to simulate file changed between requests
    File.open(tmp_mixin_file, "a") { |f| f.write("\n\n.font-bold {font-weight:bolder;}") }
    loader.preload(true)

    assert_equal 3, loader.preload.size
    assert_equal "{font-weight:bolder;}", loader.preload[".font-bold"].declarations.map(&:lexeme).join
  end

  private

  def default_config
    Deadfire.configure do |config|
      config.root_path = File.expand_path("app/stylesheets", __dir__)
      config.asset_registry.register_path("mixin.css", "vendor.css")
    end
  end
end