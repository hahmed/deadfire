# frozen_string_literal: true

module Deadfire
  class AssetRegistry
    attr_reader :settings

    def initialize
      @settings = Hash.new { |h, k| h[k] = [] }
    end

    # for a given path, load all the mixins that are registered
    # this makes it possible to load admin or other scoped mixins for a 
    # specific path
    def register_path(path, *mixins)
      normalized_mixins = Array.wrap(mixins).map { |p| full_path(p) }
      normalize_path = strip_path(path).to_s
      @settings[normalize_path].concat(normalized_mixins)
    end

    # for a given path, load all the mixins that are registered
    # e.g. admin/ or admin will load all mixins for admin, if admin is a scope
    # all mixins for admin/* will be loaded
    def mixins_for(path)
      return [] unless path.present?

      mixins = []

      mixins.concat Array.wrap(@settings[path])

      if settings["*"].present?
        mixins.concat Array.wrap(settings["*"])
      end

      scope = scope_from_path(path)

      if scope.present? && settings[scope].present?
        mixins.concat Array.wrap(settings[scope])
      end

      mixins.compact.uniq
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
        raise "Error finding asset path #{path}"
      end

      path
    end

    def css_extension(filename)
      filename.end_with?(".css") ? filename : "#{filename}.css"
    end

    def scope?(path)
      path.include?("/")
    end

    def scope_from_path(path)
      if scope?(path)
        path.split("/")[0...-1].join("/")
      else
        nil
      end
    end

    def strip_path(path)
      path.split("/").last
    end
  end
end