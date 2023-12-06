# frozen_string_literal: true

module Deadfire
  class FilenameHelper
    class << self
      def resolve_import_path(line, lineno = 0)
        path = normalize_path(line)
        potential = potential_path(path)
        ext = File.extname(path)

        if ext && valid_file?(potential)
          potential
        else
          possible_paths(path)
        end
      end

      def normalize_path(line)
        path = line.split.last
        path.gsub!("\"", "")
        path.gsub!("\'", "")
        path.gsub!(";", "")
        path
      end

      private

      def valid_file_extension?(ext)
        Deadfire::PERMISSIBLE_FILE_EXTENSIONS.include?(ext)
      end

      def valid_file?(path)
        File.exist?(path)
      end

      def possible_paths(path)
        Deadfire::PERMISSIBLE_FILE_EXTENSIONS.each do |ext|
          option = File.join(Deadfire.configuration.root_path, path + ext)
          return option if valid_file?(option)
        end
      end

      def potential_path(path)
        File.join(Deadfire.configuration.root_path, path)
      end
    end
  end
end
