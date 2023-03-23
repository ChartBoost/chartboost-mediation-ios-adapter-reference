require_relative 'common'

# Obtain the adapter version from the Adapter file
text = read_adapter_class()
adapter_version = text.match(ADAPTER_VERSION_REGEX).captures.first
fail unless !adapter_version.nil?

# Output match result to console
puts podspec_version == adapter_version
