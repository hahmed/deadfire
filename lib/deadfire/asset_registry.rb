# frozen_string_literal: true

module Deadfire
  class AssetRegistry
    attr_reader :settings

    def initialize
      @settings = Hash.new { |h, k| h[k] = [] }
    end

    def register_path(path, *mixins)
      @settings[path.to_s].concat(mixins)
    end

    # load files from the root path first, then load all the mixins from the
    # path provided
    def mixins_for(path)
      return [] unless path.present?

      Array.wrap(@settings[path]).map { |file| full_path(file) }.compact.flatten
    end

    private

    def full_path(filename)
      File.join(Deadfire.config.root_path, filename)
    end
  end
end