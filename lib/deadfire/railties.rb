# frozen_string_literal: true
require "rails"

module Deadfire
  class Railties < ::Rails::Railtie
    unless defined?(Propshaft)
      raise "Deadfire requires propshaft."
    end

    config.assets.deadfire = ActiveSupport::OrderedOptions.new

    class DeadfireCompiler < Propshaft::Compiler
      def compile(logical_path, input)
        Deadfire.parse(input, filename: logical_path, root_path: Rails.root.join("app", "assets", "stylesheets"))
      end
    end
    
    config.assets.compilers << ["text/css", DeadfireCompiler]

    initializer "deadfire.logger" do
      Deadfire.config.logger = config.assets.logger || Rails.logger
    end
  end
end