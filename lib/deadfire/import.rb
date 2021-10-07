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
        output = StringIO.new
        buffer = StringIO.new(File.read(import_path))

        while ! buffer.eof?
          current_line = buffer.gets
          if Comment.match?(current_line)
            Comment.write(buffer, current_line, output)
          elsif current_line.include?(Parser::APPLY_SELECTOR_PATTERN)
            output.write Apply.resolve(current_line, buffer.lineno)
          else
            output.write  current_line
          end
        end

        output.string
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