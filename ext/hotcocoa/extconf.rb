require 'mkmf'

system('test -d /System/Library/BridgeSupport/include')
bridge_support_required = $?.to_i

if bridge_support_required
  $stderr.puts ""
  $stderr.puts "###################################################################"
  $stderr.puts "#                                                                 #"
  $stderr.puts "#     BridgeSupport installation required.                        #"
  $stderr.puts "#     Get the latest version at: http://www.MacRuby.org/files     #"
  $stderr.puts "#                                                                 #"
  $stderr.puts "###################################################################"
  $stderr.puts ""
end

create_makefile('hotcocoa/hotcocoa')
