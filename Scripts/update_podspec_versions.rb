# Updates the podspec by replacing the adapter and partner versions.

require_relative 'common'

# Parse the version strings from the arguments
abort "Missing argument. Requires: adapter version string, partner version string." unless ARGV.count == 2
adapter_version = ARGV[0]
partner_version = ARGV[1]

# Obtain the partner SDK name from the podspec
partner_sdk_name = podspec_partner_sdk_name()

# Read the podspec file
podspec = read_podspec()

# Replace the adapter version string in the podspec
podspec = podspec.sub(PODSPEC_VERSION_REGEX, "  spec.version     = '#{adapter_version}'")

# Replace the partner SDK version string in the podspec
podspec = podspec.sub(/spec\.dependency\s*'#{partner_sdk_name}'.*$/, "spec.dependency '#{partner_sdk_name}', '#{partner_version}'")

# Write the changes
write_podspec(podspec)
