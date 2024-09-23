require "fileutils"

module Deadfire
  class Cache
    NAME = "./tmp/mixins"
    attr_reader :cache_path

    def initialize(cache_path=NAME)
      @cache_path = cache_path
      create_directory
    end

    def fetch(key)
      path = file_path(key)
      return nil unless File.exist?(path)

      Marshal.load(File.read(path))
    end

    def write(key, value)
      path = file_path(key)
      File.write(path, Marshal.dump(value))
    end

    private

    def create_directory
      FileUtils.mkdir_p(@cache_path) unless File.directory?(@cache_path)
    end

    def file_path(key)
      File.join(@cache_path, Digest::SHA1.hexdigest(key))
    end
  end
end