require "bundler/inline"
require 'benchmark'

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "deadfire", path: "./" #github: "hahmed/deadfire", branch: "main"
end

css = File.read("./benchmarks/tailwind.css")

puts css.inspect
puts "---"


time = Benchmark.measure do
  parser = Deadfire::ParserEngine.new(css)
  parser.parse
end

puts time.real
