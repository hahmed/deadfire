# frozen_string_literal: true

module Deadfire
  class FilenameHelper
    class << self
      def resolve_import_path(line, lineno = 0)
        path = normalize_path(line)
        unless path.end_with?(Deadfire::CSS_FILE_EXTENSION)
          path += Deadfire::CSS_FILE_EXTENSION
        end
        import_path = File.join(Deadfire.configuration.root_path, path)

        unless File.exist?(import_path)
          raise Deadfire::ImportException.new(import_path, lineno)
        end

        import_path
      end

      def normalize_path(line)
        path = line.split.last
        path.gsub!("\"", "")
        path.gsub!("\'", "")
        path.gsub!(";", "")
        path
      end
    end
  end
end
