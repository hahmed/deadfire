# frozen_string_literal: true
require "rails"
require "propshaft"

module Deadfire
  class Railties < ::Rails::Railtie
    initializer :deadfire do |app|
      Deadfire.configure do |deadfire_config|
        deadfire_config.root_path = Rails.root.join("app/assets/stylesheets").to_s unless deadfire_config.root_path.present?

        deadfire_config.excluded_files = []
        deadfire_config.compressed = config.assets.compressed
        deadfire_config.logger = config.assets.logger || Rails.logger
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
end
