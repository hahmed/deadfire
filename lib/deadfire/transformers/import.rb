# frozen_string_literal: true

module Deadfire::Transformers
  class Import < Transformer
    SELECTOR = "@import"
    CSS_FILE_EXTENSION = ".css"

    singleton_class.attr_accessor :import_path_cache
    self.import_path_cache = []

    def name
      "Import"
    end
    
    def matches?(line)
      line.strip.start_with?(SELECTOR)
    end
    
    def transform(line, buffer, lineno, output)
      import_path = self.class.resolve_import_path(line, lineno: buffer.lineno)
      if self.class.import_path_cache.include?(import_path)
        raise DuplicateImportException.new(import_path, buffer.lineno)
      end
      self.class.import_path_cache << import_path
      self.class.parse_import_path(import_path) # make this async and insert an empty line where we will add the imported css
    end

    class << self
      # TODO: there may be additional directories to traverse from the config e.g. node_modules?
      def resolve_import_path(current_line, lineno: 0)
        path = normalize_import_path(current_line)
        unless path.end_with?(CSS_FILE_EXTENSION)
          path += CSS_FILE_EXTENSION
        end
        import_path = File.join(Deadfire.configuration.root_path, path)

        unless File.exist?(import_path)
          raise Deadfire::ImportException.new(import_path, lineno)
        end

        import_path
      end
      
      def normalize_import_path(line)
        path = line.split.last
        path.gsub!("\"", "")
        path.gsub!("\'", "")
        path.gsub!(";", "")
        path
      end
      
      def parse_import_path(line)
        path   = normalize_import_path(line)
        parser = Deadfire::Parser.new(File.read(path), filename: path)
        # TODO: 
        # - improve this code
        # - decide on how many levels of imports we want to allow
        # - make async??
        parser.instance_eval do
          def transformers
            @transformers ||= [
              Comment.new,
              Mixin.new,
              Apply.new,
              Nesting.new,
            ]
          end
        end

        parser.call
      end
    end
  end
end