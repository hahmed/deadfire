# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "minitest/focus"

require "minitest/reporters"
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)

require "deadfire"

def fixtures_path
  File.expand_path("../deadfire/app/stylesheets", __FILE__)
end

def import(filename)
  "@import \"#{filename}\";"
end

def clear_cache
  FileUtils.rm_rf("tmp/deadfire_cache")
end

def tmp_path
  File.expand_path("../tmp", __dir__)
end