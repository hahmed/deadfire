# frozen_string_literal: true

module Deadfire
  class FilenameHelper
    class << self
      def resolve_import_path(line, lineno = 0)
        path = normalize_path(line)

        if file_extension?(path)
          return unless valid_file_extension?(path)
        end

        potential_path(path)
      end

      def normalize_path(line)
        path = line.split.last
        path.gsub!("\"", "")
        path.gsub!("\'", "")
        path.gsub!(";", "")
        path
      end

      private

      def file_extension?(path)
        path.include?(".")
      end

      def valid_file_extension?(path)
        Deadfire::PERMISSIBLE_FILE_EXTENSIONS.include?(path)
      end

      def valid_file?(path, ext)
        File.exist?(Deadfire.configuration.root_path, path + ext)
      end

      def potential_path(path)
        Deadfire::PERMISSIBLE_FILE_EXTENSIONS.each do |ext|
          if valid_file?(path, ext)
            return File.join(Deadfire.configuration.root_path, path + ext)
          end
        end
      end
    end
  end
end
