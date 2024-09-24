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

    def load(path)
      Array.wrap(@settings[path]).map do |mixin|
        # TODO...
      end
    end
  end
end