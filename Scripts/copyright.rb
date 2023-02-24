require 'find'
require 'tempfile'

# Note: This list is not meant to be exhaustive.
file_extensions_accepted = ['.h', '.m', '.swift']

# Note: This list is not meant to be exhaustive. 
exclusions = %w[Scripts .github]

# Find all resources in the Chartboost Mediation repo that match the accepted file extensions
files = []

# Script will be run from the root of the repo
Find.find(".") do |path|
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

files.each do |file_path|
  # Dynamically add comment formatting to header so we can adjust for different file types in the future
  notice_as_comment = "//" + copyright_notice.gsub(/\n/, "\n//") + "\n"
  File.open(file_path, 'r') do |f|
    contents = f.read
    if contents.start_with?(notice_as_comment)
      next
    else
      tmp = Tempfile.new("tmp")
      begin
        if contents.start_with?("//")
          # If the file starts with a comment block, replace it with the copyright header
          tmp.puts contents.sub(/^(?:\/\/[^\n]*\n)+/, notice_as_comment)
        else
          # If there's no comment at the top just insert the copyright header
          tmp.puts notice_as_comment + contents
        end

        # Replace the original file with the new one
        FileUtils.mv(tmp.path, file_path)
        files_have_been_changed = true
      ensure
        tmp.close
        tmp.unlink
      end
    end
  end
end

if files_have_been_changed
    puts "changes"
else
    puts "no-op"
end
