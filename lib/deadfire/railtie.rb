# frozen_string_literal: true
require "rails"
require "propshaft"

module Deadfire
  class Railties < ::Rails::Railtie
    config.deadfire = ActiveSupport::OrderedOptions.new
    config.deadfire.root_path = nil
    config.deadfire.excluded_files = []

    initializer :deadfire do |app|
      Deadfire.configure do |deadfire_config|
        deadfire_config.root_path = config.deadfire.root_path || app.root.join("app", "assets", "stylesheets")
        deadfire_config.excluded_files = config.deadfire.excluded_files
        deadfire_config.compressed = config.assets.compressed
        deadfire_config.logger = config.assets.logger || Rails.logger
      end
    end

    class DeadfireCompiler < ::Propshaft::Compiler
      def compile(logical_path, input)
        path = logical_path.path.to_s

        return input if Deadfire.config.excluded_files.include?(path)

        # by default, all files in the will be preprocessed
        if Deadfire.config.asset_registry.settings.empty?
          all_files = Dir.glob("#{Deadfire.config.root_path}/**/*.css")
          Deadfire.config.preprocess(*all_files)
        end

        Deadfire.parse(input, filename: logical_path.logical_path.to_s)
      end
    end
  
    config.assets.compilers << ["text/css", DeadfireCompiler]
  end
end
