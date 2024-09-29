# frozen_string_literal: true

module Deadfire
  # AssetLoader is responsible for loading mixin templates from the file system which can be used to mixin css into
  # your stylesheet.
  class AssetLoader
    attr_reader :settings

    def initialize(path)
      @path = path
      @mixins = Deadfire.config.asset_registry.settings[@path]
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
      return {} if @mixins.empty?

      data = {}

      # if the path is found and the object has already been cached, load from cache
      # otherwise load from the file system and parse, then cache it
      Array.wrap(@mixins).map do |mixin|
        
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
            Deadfire.config.logger.warn("Mixin will be overrided with a new value: #{key}")
          end

          data[key] = value
        end
      end

      data
    end

    def load_and_parse_mixin(filename)
      # NOTE: the content will need to be parsed
      content = File.read(filename)
      @cache.write(filename, content)
      # need to get the content back in a way where I get back all the mixing that are available
      Parser.new(content).mixins
    end
  end
end