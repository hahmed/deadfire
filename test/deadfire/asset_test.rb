require "test_helper"

class AsssetLoaderTest < Minitest::Test
  def setup
    @loader = Deadfire::AssetLoader.new
  end

  def teardown
    FileUtils.rm_rf(Deadfire::Cache::NAME)
  end

  def test_register_path_successfully
    @loader.register_path("app/stylsheets")
    assert_equal ["test/fixtures"], @loader.settings["app/stylsheets"]
  end
end