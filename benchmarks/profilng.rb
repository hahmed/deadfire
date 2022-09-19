require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "sassc"
  gem "deadfire", github: "hahmed/deadfire", branch: "main"
  gem 'heap-profiler'
end

css = <<~OUTPUT
h1 {
  font-size: 40px; }
  h1 code {
    font-face: Roboto Mono; }
OUTPUT

require 'heap-profiler'

HeapProfiler.report("benchmarks") do
  Deadfire.parse(css)
  # SassC::Engine.new(css).render
end