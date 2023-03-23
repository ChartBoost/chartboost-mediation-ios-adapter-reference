# Updates the main PartnerAdapter class by replacing the adapter version string.

require_relative 'common'

# Parse the new version string from the arguments
abort "Missing argument. Requires: version string." unless ARGV.count == 1
new_version = ARGV[0]

# Read the main adapter class file
adapter_class = read_adapter_class()

# Replace the partner adapter version
adapter_class = adapter_class.sub(ADAPTER_VERSION_REGEX, "    let adapterVersion = \"#{new_version}\"")

# Write the changes
write_adapter_class(adapter_class)
