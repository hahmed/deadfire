require "stringio"

content = StringIO.new File.read(File.dirname(__FILE__) + '/../benchmarks/basecamp.css')

def write_to_buffer(css)
  buffer = StringIO.new
  
  while ! css.eof?
    line = css.gets
    buffer.write line
  end

  buffer.string
end

file = File.new(File.dirname(__FILE__) + '/../benchmarks/basecamp.css')
def write_from_file(css)
  buffer = []
  css.each_line do |line|
    buffer << line
  end
  buffer.join("\n")
end

require "benchmark/ips"

Benchmark.ips do |x|
  x.report("buffer_gets") { write_to_buffer(content) }
  x.report("file-each_line") { write_from_file(file) }
  x.compare!
end

# TODO:
# maybe expand this benchmark?

# ruby -Ilib:test test/