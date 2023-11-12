# frozen_string_literal: true

module Deadfire
  class Configuration
    attr_reader :directories, :root_path, :keep_comments, :keep_whitespace

    def initialize
      @directories = []
      @root_path = ""
      @keep_comments = true
      @keep_whitespace = true
    end

    def root_path=(value)
      unless Dir.exist?(value)
        raise DirectoryNotFoundError.new("Root not found #{value}")
      end
      @root_path = value
    end

    def keep_comments=(value)
      @keep_comments = value
    end

    def keep_whitespace=(value)
      @keep_whitespace = value
    end
  end
end
