# frozen_string_literal: true

module Deadfire
  # AssetLoader is responsible for loading mixin templates from the file system which can be used to mixin css into
  # your stylesheet.
  class AssetLoader
    attr_reader :settings

    def initialize(path)
      @path = path
      @cache = ActiveSupport::Cache::FileStore.new("tmp/deadfire_cache")
    end

    def cache_css(name, value)
      cached_mixins[name] = value
    end
    
    def cached_css(name)
      cached_mixins[name]
    end

    def preload(force_reload=false)
      if force_reload
        @_cached_mixins = nil
      end

      cached_mixins
    end
    
    private

    def cached_mixins
      @_cached_mixins ||= load_mixins
    end

    def load_mixins    
      Array.wrap(Deadfire.configuration.asset_registry.mixins_for(@path)).each.with_object({}) do |filename, data|
        unless File.exist?(filename)
          Deadfire.config.logger.error("Mixin not found: #{filename}")
          next
        end

        stat = File.stat(filename)
        key = "#{filename}-#{stat.mtime.hash}"

        content = @cache.fetch(key)

        if content.nil?
          content = load_and_parse_mixin(filename, key)
        end

        content.each do |key, value|
          Deadfire.config.logger.warn("Mixin '#{key}' will be overrided with a new value.") if data.key?(key)

          data[key] = value
        end
      end
    end

    def load_and_parse_mixin(filename, key)
      content = File.read(filename)
      mixins = ParserEngine.new(content).load_mixins
      @cache.write(key, mixins)
      mixins
    end
  end
end