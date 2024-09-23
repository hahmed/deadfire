require "test_helper"

class CacheTest < Minitest::Test
  def setup
    @cache = Deadfire::Cache.new
  end

  def teardown
    FileUtils.rm_rf(Deadfire::Cache::NAME)
  end

  def test_stores_file_in_cache
    hash = { "text-blue" => "color: blue;" }
    @cache.write("test", hash)
    
    assert_equal @cache.fetch("test"), hash
  end
end