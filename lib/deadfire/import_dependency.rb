# frozen_string_literal: true

module Deadfire
  class ImportDependency
    singleton_class.attr_accessor :files
    self.files = Hash.new { |h, k| h[k] = [] }

    class << self
      def add(file, dependency)
        unless @files[file].include?(dependency)
          @files[file] << dependency
        end
      end

      def fetch(file)
        @files[file] || []
      end

      def remove(file)
        @files.delete(file)
        @files.each { |key, deps| deps.delete(file) }
      end

      def dependents_of(file)
        @files.select { |key, deps| deps.include?(file) }.keys
      end

      def reset
        @files = Hash.new { |h, k| h[k] = [] }
      end
    end
  end
end