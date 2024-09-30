# frozen_string_literal: true

module Deadfire
  # AssetLoader is responsible for loading mixin templates from the file system which can be used to mixin css into
  # your stylesheet.
  class AssetLoader
    attr_reader :settings

    def initialize(path)
      @path = path
      @mixin_files = Deadfire.config.asset_registry.settings[@path]
      @cache = Rails.cache
    end

    def cache_css(name, value)
      cached_mixins[name] = value
    end
    
    def cached_css(name)
      cached_mixins[name]
    end

    def preload
      cached_mixins
    end
    
    private

    def cached_mixins
      @_cached_mixins ||= load_mixins
    end

    def load_mixins
      data = {}

      return data if @mixin_files.empty?

      # if the path is found and the object has already been cached, load from cache
      # otherwise load from the file system and parse, then cache it
      Array.wrap(@mixin_files).map do |mixin|
        
        filename = File.join(Deadfire.config.root_path, "stylesheets", "#{mixin}")

        # TODO: add a better key than just the filename, content can change
        content = @cache.fetch(filename)

        if content.nil?
          unless !File.exist?(filename)
            Deadfire.config.logger.error("Mixin not found: #{mixin}")
            next
          end
          content = load_and_parse_mixin(filename)
        end

        # the content will appear in a hash? then we need to safely push that into the data hash
        content.each do |key, value|
          if data.key?(key)
            Deadfire.config.logger.warn("Mixin '#{key}' will be overrided with a new value.")
          end

          data[key] = value
        end
      end

      data
    end

    def load_and_parse_mixin(filename)
      content = File.read(filename)
      mixins = Parser.new(content).mixins
      @cache.write(filename, mixins)
      mixins
    end
  end
end