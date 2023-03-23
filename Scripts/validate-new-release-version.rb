# Validates an adapter version string, checking it is well-formed and that it hasn't been released yet.

# Parse the new version string from the arguments
abort "Missing argument. Requires: version string." unless ARGV.count == 1
new_version = ARGV[0]

# Check that the version is 5 or 6 digits long
new_version_components = new_version.split('.')
if new_version_components.count < 5 || new_version_components.count > 6
  puts false
  exit 0
end

# Check if a tag for that version already exists in the remote
# This command:
# 1. Fetches all tags from origin
# 2. Lists all tags that match the new version string
# 3. Returns the new version string if the corresponding tag was found, empty string otherwise
version_tag_check = %x( git fetch origin --tags --prune --prune-tags --force && git tag -l "#{new_version}" | head -1)

# Output result to console: success if tag not found, failure otherwise.
puts version_tag_check.empty?
