require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "sassc"
  gem "deadfire", github: "hahmed/deadfire", branch: "main"
  gem "syntax_tree-css"

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
  font-family: Roboto Mono;
  font-size: 12px;
  color: gray;
}

.banner {
  border: 1px solid #ccc;
}
CSS

def dartsass
  system "sass benchmarks/input.scss output.css", exception: true
end

Benchmark.ips do |x|
  x.config(:time => 5, :warmup => 2)

  x.report("dartsass") { dartsass }
  x.report("deadfire")    { Deadfire.parse(css) }
  x.report("sassc")       { SassC::Engine.new(css).render }
  x.report("sytanx_tree") { SyntaxTree::CSS.parse(css) }
  x.compare!
end

# FYI
# Warming up --------------------------------------
#             dartsass     1.000  i/100ms
#             deadfire     1.088k i/100ms
#                sassc    27.000  i/100ms
#          sytanx_tree    19.000  i/100ms
# Calculating -------------------------------------
#             dartsass      6.605  (± 0.0%) i/s -     33.000  in   5.005992s
#             deadfire     11.507k (± 3.6%) i/s -     57.664k in   5.017772s
#                sassc    308.909  (± 6.2%) i/s -      1.539k in   5.002165s
#          sytanx_tree    210.732  (± 9.0%) i/s -      1.045k in   5.005951s

# Comparison:
#             deadfire:    11507.3 i/s
#                sassc:      308.9 i/s - 37.25x  (± 0.00) slower
#          sytanx_tree:      210.7 i/s - 54.61x  (± 0.00) slower
#             dartsass:        6.6 i/s - 1742.19x  (± 0.00) slower
