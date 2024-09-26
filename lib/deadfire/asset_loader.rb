# frozen_string_literal: true

module Deadfire
  # AssetLoader is responsible for loading mixin templates from the file system which can be used to mixin css into
  # your stylesheet.
  class AssetLoader
    attr_reader :settings

    def initialize
      @settings = Hash.new { |h, k| h[k] = [] }
      @cache = Deadfire::Cache.new
    end

    def register_path(path, *mixins)
      @settings[path.to_s].concat(mixins)
    end

    def cached_css(name)
      # TODO...
    end

    def cache_css(name, value)
      # TODO
    end

    def load(path)
      return if @settings[path].empty?

      # if the path is found and the object has already been cached, load from cache
      # otherwise load from the file system and parse, then cache it
      Array.wrap(@settings[path]).map do |mixin|
        # TODO...
      end
    end
  end
end