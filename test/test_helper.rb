$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "deadfire"

require "minitest/autorun"

def fixtures_path
  File.expand_path("../deadfire/app/stylesheets", __FILE__)
end

def buffer(content: "")
  Deadfire::CssBuffer.new(content)
end