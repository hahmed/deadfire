module Deadfire
  class Configuration
    attr_accessor :directories

    def initialize
      @directories = []
    end
  end
end