# frozen_string_literal: true
require "rails"
require "propshaft"

module Deadfire
  class Railties < ::Rails::Railtie
    class DeadfireCompiler < Propshaft::Compiler
      def compile(logical_path, input)
        # NOTE: this should change the file...
        Deadfire.parse(input, filename: logical_path)
      end
    end
  
    config.assets.compilers << ["text/css", DeadfireCompiler]

    initializer "excluded paths" do
      config.assets.excluded_paths << [Rails.root.join("app", "assets", "vendor")]
    end

    config.after_initialize do
      # config.assets.paths -= [Rails.root.join("app", "assets", "stylesheets", "vendor")]
      config.deadfire = ActiveSupport::OrderedOptions.new
      config.deadfire.root_path = Rails.root.join("app", "assets", "stylesheets")

      Deadfire.configure do |deadfire_config|
        deadfire_config.root_path = config.deadfire.root_path
        deadfire_config.compressed = config.assets.compressed
        deadfire_config.logger = config.assets.logger || Rails.logger
      end
    end
  end
end