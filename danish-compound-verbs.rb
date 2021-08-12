#!/usr/bin/env ruby

prefixes = %w[
  und
  ind ud
  med
  mod
  op ned
  på
  an
  af til fra
  over under
  god
  gen
  om
  be
  for
].sort.uniq

roots = %w[
  gå
  være
  levere
  lyse
  vise
  kende
  skabe
  sætte
  melde
  tage
  stå
  give
  løbe
  komme
  virke
  arbejde
  sige
  søge
  se
  tale
].sort.uniq

regex = "^(#{prefixes.join("|")})(#{roots.join("|")})$"
compiled = Regexp.new(regex)

require 'set'
matches = Hash.new { |h, k| h[k] = Hash.new }

`aspell -l da dump master`.each_line do |line|
  if match = line.match(compiled)
    matches[match[1]][match[2]] = true
  end
end

def get_definition(item)
  "?"
end

def print_row(*cells)
  puts cells.join("\t")
end

print_row("", *prefixes)
roots.each do |root|
  print_row(root, *prefixes.map { |prefix| matches[prefix].include?(root) ? "Y" : "" })
end

require 'json'
File.open("out/danish-compound-verbs.combinations.js", "w") do |f|
  f.write "combinations(#{JSON.generate(matches)});\n"
end

File.open("danish-compound-verbs.definitions.txt", "w") do |f|
  f.puts "// prefixes"
  prefixes.each { |w| f.puts "#{w}." }
  f.puts

  f.puts "// roots"
  roots.each { |w| f.puts "at #{w}." }
  f.puts

  words = matches.map do |prefix, inner|
    inner.keys.map do |root|
      prefix + root
    end
  end.flatten.sort
  f.puts "// combinations"
  words.each { |w| f.puts "at #{w}." }
  f.puts
end
