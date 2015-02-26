# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack/realtime/version'

Gem::Specification.new do |spec|
  spec.name          = "slack-realtime"
  spec.version       = Slack::Realtime::VERSION
  spec.authors       = ["Kazuki AKAMINE"]
  spec.email         = ["kazzone87@gmail.com"]
  spec.description   = %q{Slack realtime api eventmachine with websocket.}
  spec.summary       = %q{Slack realtime api eventmachine with websocket.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "httpclient"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
