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
  end
end