# frozen_string_literal: true
require "rails"

module Deadfire
  class Railties < ::Rails::Railtie
    unless defined?(Propshaft)
      require "propshaft"
    end

    class DeadfireCompiler < Propshaft::Compiler
      def compile(logical_path, input)
        Deadfire.parse(input, filename: logical_path)
      end
    end
  
    config.assets.compilers << ["text/css", DeadfireCompiler]
    
    config.after_initialize do
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