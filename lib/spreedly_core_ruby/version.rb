module SpreedlyCore
  puts "============================================="
  puts "SpreedlyCore - defining VERSION"
  puts caller
  puts "============================================="
  Version = VERSION = "0.3.0" #unless const_defined?(VERSION)
  ApiVersion = API_VERSION = "v1" #unless const_defined?((API_VERSION)
end
