require 'erb'
name = ENV["NAME"]
email = ENV["EMAIL"]
signing_key = ""

if ENV.key?("SIGNINGKEY")
  signing_key = ENV["SIGNINGKEY"]
end

home = ENV["HOME"]
template_location = home + '/.config/gitconfig/config.toml.erb'
output_location = home + '/.config/gitconfig/gitconfig.toml'

template = ERB.new(File.read(template_location))
rendered_tmpl = template.result(binding)
File.write(output_location, rendered_tmpl)
