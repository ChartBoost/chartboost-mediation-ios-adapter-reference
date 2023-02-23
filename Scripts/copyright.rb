require 'find'
require 'tempfile'

# Note: This list is not meant to be exhaustive.
file_extensions_accepted = ['.h', '.m', '.swift']

# Note: This list is not meant to be exhaustive. 
exclusions = %w[Scripts .github]

# Find all resources in the Chartboost Mediation repo that match the accepted file extensions
files = []

# We expect to be in the Scripts folder so go one level up to the root of the repo
Find.find("..") do |path|
  files << path if file_extensions_accepted.include? File.extname(path)
end

# Filter anything that is empty or not a file
files = files.reject { |file| file.empty? || !File.file?(file) }

# Filter against pre-defined exclusions
exclusions.each do |exclusion|
  files = files.reject { |file| file =~ /.*#{exclusion}.*/ }
end

if files.empty?
  puts "no-op"
  exit
end

copyright_notice = " Copyright 2022-#{Time.now.year} Chartboost, Inc.\n\n Use of this source code is governed by an MIT-style\n license that can be found in the LICENSE file."
files_have_been_changed = false

files.each do |file|
  # Dynamically add comment formatting to header so we can adjust for different file types in the future
  notice_as_comment = "//" + copyright_notice.gsub(/\n/, "\n//") + "\n"
  File.open(file, 'r+') do |f|
    contents = f.read
    if contents.start_with?(notice_as_comment)
      next
    else
      f.rewind
      # If the file starts with a comment block, replace it with the copyright header
      if contents.start_with?("//")
        f.puts contents.gsub(/^(?:\/\/[^\n]*\n)+/, notice_as_comment)
      # If there's no comment at the top just insert the copyright header
      else
        f.puts notice_as_comment + contents
      end
      files_have_been_changed = true
    end
  end
end

if files_have_been_changed
    puts "changes"
else
    puts "no-op"
end
