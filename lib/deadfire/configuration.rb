# frozen_string_literal: true
require "logger"

module Deadfire
  class Configuration
    attr_reader :directories, :root_path, :compressed, :logger, :supressed

    def initialize
      @directories = []
      @root_path = ""
      @compressed = false
      @logger = Logger.new(STDOUT, level: :warn)
      @supressed = true
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

    def logger=(value)
      @logger = value
    end

    def supressed=(value)
      @supressed = value
    end
  end
end
