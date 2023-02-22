require 'find'
require 'tempfile'

# Note: This list is not meant to be exhaustive. 
# For now, some common file extensions for Android are included below.
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

copyright_notice = " Copyright 2022-#{Time.now.year} Chartboost, Inc.\n\nUse of this source code is governed by an MIT-style\nlicense that can be found in the LICENSE file."

# Insert a commented copyright notice at the top of the file
def insert_copyright_notice(file, notice_as_comment)
    File.open(file, 'r+') do |f|
        contents = f.read
        f.rewind
        f.puts notice_as_comment + contents
    end
end

files_have_been_changed = false

files.each do |file|
    # If the notice text changes, this will need to be updated
    if File.readlines(file).grep(/Copyright 2022/).any?
        current_year = Time.now.year

        # If the notice text changes, this will need to be updated
        if File.readlines(file).grep(/Copyright 2022-#{current_year}/).any?
            next
        else
            File.open(file, 'r') do |f|
                files_have_been_changed = true
                contents = f.read

                # If the notice text changes, this will need to be updated
                contents.gsub!(/Copyright 2022-20\d\d/, "Copyright 2022-#{current_year}")
                File.open(file, 'w') do |f|
                    f.puts contents
                end
            end
        end
    # We didn't find any copyright notice, so we should insert one
    else
        # All the currently accepted filetypes happen to use the same comment style
        file_extensions_accepted.include? File.extname(file)
        notice_as_comment = "//" + copyright_notice.gsub(/\n/, "\n// ") + "\n"
        insert_copyright_notice(file, notice_as_comment)
        files_have_been_changed = true
    end
end

if files_have_been_changed
    puts "changes"
else
    puts "no-op"
end
