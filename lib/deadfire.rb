require_relative "deadfire/version"
require_relative "deadfire/configuration"
require_relative "deadfire/processor"
require_relative "deadfire/apply"
require_relative "deadfire/import"

module Deadfire
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def execute(file)
      Processer.run(file)
    end
  end
end
