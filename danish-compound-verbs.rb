#!/usr/bin/env ruby

require 'json'
require 'set'

class TranslationsCache

  def initialize(file)
    @file = file
    @data = begin
              JSON.parse(IO.read(file))
            rescue Errno::ENOENT
              {}
            end
  end

  def interactive_multi_get(words)
    words = words.to_set
    missing = words - @data.keys
    interactive_fill(missing)
    words.map do |word|
      [word, @data[word]]
    end.to_h
  end

  private

  def interactive_fill(missing)
    missing = missing.to_set.to_a
    return if missing.empty?

    require 'open3'
    text = missing.each_with_index.map { |word, index| "#{index}. #{word}." }.join("\n")
    Open3.pipeline_w("pbcopy") { |i, ts| i.print text }

    puts "Text is copied to the clipboard.\n"
    puts "Translate from Danish to English using https://translate.google.co.uk/?sl=da&tl=en ,"
    puts "copy the results to the clipboard, then press return."
    $stdin.readline

    result = `pbpaste`
    # TODO transform ZWSP to spaces
    modified = false

    result.scan(/(\d+)\.(.*?)\./).each do |index, english|
      danish = missing[index.to_i]
      english.strip!

      if english == danish
        puts "Ignoring #{danish}=#{english} because it's the same. Maybe Google just didn't translate that word."
        puts "Maybe manually add it to #{@file}"
      else
        modified = true
        @data[danish] = english
      end
    end

    if modified
      require 'tempfile'
      Tempfile.open(@file, File.dirname(@file)) do |f|
        @data = @data.entries.sort_by(&:first).to_h
        f.puts(JSON.pretty_generate(@data))
        f.chmod 0o644
        f.flush
        File.rename f.path, @file
      end
    end
  end

end

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
  trykke
  trække
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

require 'json'
File.open("out/danish-compound-verbs.combinations.js", "w") do |f|
  f.write "combinations(#{JSON.generate(matches)});\n"
end

File.open("out/danish-compound-verbs.definitions.js", "w") do |f|
  words = [
    *prefixes,
    *roots.map { |root| "at " + root },
    *matches.map do |prefix, inner|
      inner.keys.map do |root|
        "at " + prefix + root
      end
    end.flatten.sort,
  ].uniq

  defs = TranslationsCache.new("translations.json").interactive_multi_get(words)
  f.write "definitions(#{JSON.generate(defs)});\n"
end
