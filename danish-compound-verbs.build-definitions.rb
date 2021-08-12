#!/usr/bin/env ruby

file1 = IO.read("danish-compound-verbs.definitions.txt").lines
file2 = IO.read("danish-compound-verbs.definitions.out").lines

puts "definitions({"

file1.zip(file2).each do |a, b|
  if a.end_with?(".\n")
    a.sub!(".\n", "")
    b.sub!(".\n", "")
    a.sub!("at ", "")
    b.sub!("to ", "")

    if a != b
      # p [a, b]
      puts "  #{a}: \"#{b}\","
    else
      puts "  // nothing for #{a}"
    end
  else
    print "  " + a
  end
end

puts "});"
