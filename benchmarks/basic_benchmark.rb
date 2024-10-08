require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "sassc"
  gem "deadfire", github: "hahmed/deadfire", branch: "main"
  gem "syntax_tree-css"
  gem "sass-embedded"

  gem "benchmark-ips"
end

css = <<~CSS
/* My very first css file! */
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
/* Just
a
random
comment */
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

.button--block { min-width:100% !important }

code {
  font-family: Roboto Mono;
  font-size: 12px;
  color: gray;
}

/* I like code                  blocks!!!!!======= */

.banner {
  border: 1px solid #ccc;
}
CSS

Benchmark.ips do |x|
  x.config(:time => 5, :warmup => 2)

  # x.report("dartsass") { dartsass }
  x.report("deadfire")    { Deadfire.parse(css) }
  x.report("sassc")       { SassC::Engine.new(css).render }
  x.report("sytanx_tree") { SyntaxTree::CSS.parse(css) }
  x.report("dart sass")   { Sass.compile_string(css) }
  x.compare!
end

# May 2024: Re-added dart sass
# Warming up --------------------------------------
#             deadfire   172.000 i/100ms
#                sassc    85.000 i/100ms
#          sytanx_tree    79.000 i/100ms
#            dart sass   520.000 i/100ms
# Calculating -------------------------------------
#             deadfire      1.680k (± 0.9%) i/s -      8.428k in   5.018094s
#                sassc    816.292 (± 0.2%) i/s -      4.165k in   5.102378s
#          sytanx_tree    750.421 (± 1.9%) i/s -      3.792k in   5.054908s
#            dart sass      5.225k (± 4.7%) i/s -     26.520k in   5.090927s

# Comparison:
#            dart sass:     5224.7 i/s
#             deadfire:     1679.7 i/s - 3.11x  slower
#                sassc:      816.3 i/s - 6.40x  slower
#          sytanx_tree:      750.4 i/s - 6.96x  slower

# Nov 2023: (Note: removed dart sass because I don't have it installed, need to re-run again)
# Warming up --------------------------------------
#             deadfire   116.000  i/100ms
#                sassc    69.000  i/100ms
#          sytanx_tree    64.000  i/100ms
# Calculating -------------------------------------
#             deadfire      1.164k (± 1.2%) i/s -      5.916k in   5.084777s
#                sassc    695.721  (± 1.3%) i/s -      3.519k in   5.059025s
#          sytanx_tree    635.684  (± 3.3%) i/s -      3.200k in   5.040489s

# Comparison:
#             deadfire:     1163.6 i/s
#                sassc:      695.7 i/s - 1.67x  slower
#          sytanx_tree:      635.7 i/s - 1.83x  slower


# Sep 2022:
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
