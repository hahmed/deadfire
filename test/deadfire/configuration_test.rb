require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    Deadfire.reset
  end

  def test_assigns_directories
    Deadfire.configure do |config|
      config.directories << "app/css"
    end

    assert_equal ["app/css"], Deadfire.configuration.directories
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
      config.directories << "app/css"
    end

    refute Deadfire.configuration.directories.empty?
    Deadfire.reset
    assert Deadfire.configuration.directories.empty?
  end

  def test_assigns_suppressed
    Deadfire.configure do |config|
      config.supressed = false
    end

    refute Deadfire.configuration.supressed
  end

  def test_assigns_logger
    Deadfire.configure do |config|
      config.logger = Logger.new(STDERR)
    end

    assert_instance_of Logger, Deadfire.configuration.logger
  end
end