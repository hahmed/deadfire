# frozen_string_literal: true

module Deadfire
  class Import
    FILE_EXTENSION = ".css"

    attr_reader :lineno, :import_path

    def initialize(import_path, lineno)
      @import_path = import_path
      @lineno      = lineno
    end

    def resolve
      lookup_path = resolve_import_path(import_path)

      unless File.exist?(lookup_path)
        raise FileNotFoundError.new("File not found #{lookup_path}")
      end

      f = File.open(lookup_path, "r")
      f.read
    end

    class << self
      def parse_import_path(line)
        path = line.split.last
        path.gsub!("\"", "")
        path.gsub!("\'", "")
        path.gsub!(";", "")
        path
      end
    end

    private

      # TODO: there may be additional directories to traverse from the config
      def resolve_import_path(import_path)
        path = self.class.parse_import_path(import_path)
        unless path.end_with?(FILE_EXTENSION)
          path += FILE_EXTENSION
        end
        File.join(Deadfire.configuration.root_path, path)
      end
  end
end