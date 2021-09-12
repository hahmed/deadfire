require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "sassc"
  gem "deadfire", github: "hahmed/deadfire", branch: "main"

  gem "benchmark-ips"
end

css = <<~OUTPUT
h1 {
  font-size: 40px; }
  h1 code {
    font-face: Roboto Mono; }
OUTPUT

Benchmark.ips do |x|
  x.report("deadfire") { Deadfire.parse(css) }
  x.report("sassc")      { SassC::Engine.new(css).render }
  x.compare!
end

