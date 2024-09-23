module Deadfire
  class AssetLoader
    attr_reader :settings

    def initialize
      @settings = Hash.new([])
      @cache = Deadfire::Cache.new
    end

    def register_path(path, *mixins)
      @settings[path] << mixins
    end

    def default(*mixins)
      @settings[:default] = mixins
    end

    def load(path=nil)
      mixins = if path.nil?
        @settings[:default]
      else
        @settings[path]
      end

      mixins.map do |mixin|
        # expand file or load from cache
      end
    end
  end
end