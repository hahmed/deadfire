require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "sassc"
  gem "deadfire", github: "hahmed/deadfire", branch: "main"

  gem "benchmark-ips"
end

css = <<~CSS
body {
  font-family: helvetica, arial, sans-serif;
  font-size: calc(1.3em + 0.5vw);
  line-height: 1;
  margin: 0;
  padding: 0;
  color: #1d2d35;
  background-color:#ffefef;
}

h1 {
  font-size: 40px; 
}

a {
  font-size: 1em;
  vertical-align: baseline;
  background: transparent;
  margin: 0;
  padding: 0;
  color: inherit;
  transition: all 0.2s ease;
  transition-property: text-decoration-color, text-decoration-thickness, text-decoration-width;
  text-decoration-thickness: 0.1em;
  text-decoration-width: 0.1rem
}

.button--block {
  min-width:100% !important
}

code {
  font-face: Roboto Mono;
  font-size: 12px;
  color: gray;
}

.banner {
  border: 1px solid #ccc;
}
CSS

Benchmark.ips do |x|
  x.report("deadfire") { Deadfire.parse(css) }
  x.report("sassc")    { SassC::Engine.new(css).render }
  x.compare!
end
