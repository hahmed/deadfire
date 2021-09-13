# frozen_string_literal: true

module Deadfire
  class Import
    FILE_EXTENSION = ".css"

    class << self
      # TODO: there may be additional directories to traverse from the config e.g. node_modules?
      def resolve_import_path(current_line, lineno)
        path = parse_import_path(current_line)
        unless path.end_with?(FILE_EXTENSION)
          path += FILE_EXTENSION
        end
        import_path = File.join(Deadfire.configuration.root_path, path)

        unless File.exist?(import_path)
          raise ImportException.new(import_path, lineno)
        end

        import_path
      end

      def resolve(import_path)
        f = File.open(import_path, "r")
        f.read # apply mixins
      end

      def parse_import_path(line)
        path = line.split.last
        path.gsub!("\"", "")
        path.gsub!("\'", "")
        path.gsub!(";", "")
        path
      end
    end
  end
end