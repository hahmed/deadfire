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

  def test_add_prefixer
    Deadfire.configure do |config|
      config.add_prefixer("admin.css", "admin-")
    end

    assert_equal({"admin.css" => "admin-"}, Deadfire.configuration.prefixers)
  end

  def test_raises_error_when_prefix_is_nil
    assert_raises(ArgumentError) do
      Deadfire.configure do |config|
        config.add_prefixer("admin.css", nil)
      end
    end
  end

  def test_prefixer_adds_dash_when_not_present
    Deadfire.configure do |config|
      config.add_prefixer("admin.css", "admin")
    end

    assert_equal({"admin.css" => "admin-"}, Deadfire.configuration.prefixers)
  end
end