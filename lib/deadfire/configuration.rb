# frozen_string_literal: true

module Deadfire
  class Configuration
    attr_reader :directories, :root_path, :compressed

    def initialize
      @directories = []
      @root_path = ""
      @compressed = false
    end

    def root_path=(value)
      return if value.nil?

      unless Dir.exist?(value)
        raise DirectoryNotFoundError.new("Root not found #{value}")
      end
      @root_path = value
    end

    def compressed=(value)
      @compressed = value unless value.nil?
    end
  end
end
