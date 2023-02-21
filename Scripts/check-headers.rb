require 'find'
require 'tempfile'

# Array of consecutive header lines that should be at the top of all source files
HEADER = ["// Copyright 2022-2023 Chartboost, Inc.",
		"//",
		"// Use of this source code is governed by an MIT-style",
		"// license that can be found in the LICENSE file."]

def file_header_conforms(file_path)
	header_lines = []
	enumerator = File.foreach(file_path)
	loop do
		line = enumerator.next
		# loop until there are two consecutive rows that are not comments
		if !line.start_with?("//") && !enumerator.peek.start_with?("//")
			break
		end
		header_lines.push(line)
	end

	# Return false if the file's header is the wrong number of lines
	if header_lines.length != HEADER.length
		return false
	end

	# Return false if any of the file's header lines don't match the template
	for i in 0..HEADER.length - 1
		# Use .rstrip to ignore any trailing whitespace from the file
		if header_lines[i].rstrip != HEADER[i]
			return false
		end
	end

	# If all checks have passed, return true
	return true
end

files_have_been_changed = false

Find.find("..") do |path|
	if File.extname(path) == ".swift" && !file_header_conforms(path)
		# Replace the file with a copy that has the correct header
		tmp = Tempfile.new("tmp")
		begin
			# Write the standard header to the beginning of our new file
			HEADER.each { |line| tmp.write(line + "\n")}
			# One blank line after the header
			tmp.write("\n")
			# Get an enumerator for the file we're replacing
			source = File.foreach(path)
			# Skip all the header lines in the original file
			loop do
				line = source.next
				# loop until there are two consecutive rows that are not comments
				if !line.start_with?("//") && !source.peek.start_with?("//")
					# Usually, the first non-comment line is blank, but sometimes it's code
					tmp.write(line) unless line.strip.empty?
					break
				end
			end

			# Starting from where the previous loop stopped, copy the rest of the file
			loop do
				# loop will catch the StopIteration exception when we reach EOF
				tmp.write(source.next)
			end
			# Replace the original file with the new one
			FileUtils.mv(tmp.path, path)
			files_have_been_changed = true
		ensure
			tmp.close
			tmp.unlink
		end
	end
end

if files_have_been_changed
	puts "changes"
else
	puts "no-op"
end
