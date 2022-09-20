# frozen_string_literal: true

module Deadfire
  class Configuration
    attr_reader :directories, :root_path, :keep_comments

    def initialize
      @directories = []
      @root_path = ""
      @keep_comments = true
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
  end
end