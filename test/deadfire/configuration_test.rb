require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    Deadfire.reset
  end

  def test_assigns_directories
    Deadfire.configure do |config|
      config.directories << "app/js"
    end

    assert_equal ["app/js"], Deadfire.configuration.directories
  end

  def test_assigns_excluded_files
    Deadfire.configure do |config|
      config.excluded_files << "app/js"
    end

    assert_equal ["app/js"], Deadfire.configuration.excluded_files
  end

  def test_raises_error_when_invalid_root_path
    assert_raises(Deadfire::DirectoryNotFoundError) do
      Deadfire.configure do |config|
        config.root_path = "fake_dir"
      end
    end
  end

  def test_reset_configuration
    Deadfire.configure do |config|
      config.directories << "app/js"
    end

    refute Deadfire.configuration.directories.empty?
    Deadfire.reset
    assert Deadfire.configuration.directories.empty?
  end
end