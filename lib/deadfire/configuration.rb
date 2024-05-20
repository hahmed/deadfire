# frozen_string_literal: true
require "logger"

module Deadfire
  class Configuration
    attr_reader :directories, :root_path, :compressed, :logger, :supressed, :prefixers

    def initialize
      @directories = []
      @root_path = ""
      @compressed = false
      @logger = Logger.new(STDOUT, level: :warn)
      @supressed = true
      @prefixers = {}
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

    # Add an import path, when imported all the utility classes will be prefixed
    # Example:
    #  Deadfire.configure do |config|
    #    config.add_prefixer("admin.css", "admin-")
    #  end
    # =>
    # file: assets/stylesheets/admin.css
    # .user { color: red; }
    # file: assets/stylesheets/application.css
    # import "admin"
    # .admin-user { color: red; }
    def add_prefixer(path, prefix)
      @prefixers[path] = prefix
    end
  end
end
