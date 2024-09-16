# frozen_string_literal: true
require "rails"
require "propshaft"

module Deadfire
  class Railties < ::Rails::Railtie
    config.deadfire = ActiveSupport::OrderedOptions.new
    config.deadfire.root_path = Rails.root.join("app", "assets", "stylesheets") if Rails.root
    config.deadfire.excluded_files = []

    config.after_initialize do
      Deadfire.configure do |deadfire_config|
        deadfire_config.root_path = config.deadfire.root_path
        deadfire_config.excluded_files = config.deadfire.excluded_files
        deadfire_config.compressed = config.assets.compressed
        deadfire_config.logger = config.assets.logger || Rails.logger
      end
    end

    class DeadfireCompiler < ::Propshaft::Compiler
      def compile(logical_path, input)
        path = logical_path.path.to_s

        return input if Deadfire.config.excluded_files.include?(path)

        Deadfire.parse(input, filename: path)
      end
    end
  
    config.assets.compilers << ["text/css", DeadfireCompiler]
  end
end
