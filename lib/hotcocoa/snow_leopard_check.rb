# Meant to painlessly probe for BridgeSupport Preview
#
# The first rescue block will no-op in lib/hotcocoa.rb
# since the framework is already set.
begin
  NSWindow
rescue NameError
  framework 'Cocoa'
end

# The second rescue block will bail in a meaningful way
# if BridgeSupport is absent.
begin
  CGRectZero
rescue NameError
  warn 'BridgeSupport Preview required for this installation.'
  warn 'Get the latest version from: http://www.macruby.org/files/'
  exit(Errno::EOPNOTSUPP::Errno)
end
