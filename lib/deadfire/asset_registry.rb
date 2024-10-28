# frozen_string_literal: true

module Deadfire
  class AssetRegistry
    attr_reader :settings

    def initialize
      @settings = Hash.new { |h, k| h[k] = [] }
    end

    def register_path(path, *mixins)
      normalized_paths = Array.wrap(mixins).map { |p| full_path(p) }
      @settings[path.to_s].concat(normalized_paths)
    end

    def mixins_for(path)
      return [] unless path.present?

      Array.wrap(@settings[path]).compact
    end

    def clear
      @settings.clear
    end

    private

    def full_path(filename)
      if File.exist?(filename)
        filename
      else
        normalize_path(filename)
      end
    end

    def normalize_path(filename)
      path = File.join(Deadfire.config.root_path, filename)
      path = css_extension(path)

      unless File.exist?(path)
        raise "Error finding asset path"
      end

      path
    end

    def css_extension(filename)
      filename.end_with?(".css") ? filename : "#{filename}.css"
    end
  end
end