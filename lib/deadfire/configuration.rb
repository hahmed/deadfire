module Deadfire
  class Configuration
    attr_reader :directories, :root_path

    def initialize
      @directories = []
      @root_path = ""
    end

    def root_path=(value)
      unless Dir.exist?(value)
        raise DirectoryNotFoundError.new("Root not found #{value}")
      end
      @root_path = value
    end
  end
end