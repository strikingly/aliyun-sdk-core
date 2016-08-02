# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aliyun_sdk/core/version'

Gem::Specification.new do |spec|
  spec.platform      = Gem::Platform::RUBY
  spec.name          = "aliyun-sdk-core"
  spec.version       = AliyunSDK::Core::VERSION
  spec.authors       = ["Daniel Gong"]
  spec.email         = ["daniel@strikingly.com"]
  spec.summary       = %q{The core gem for all Aliyun API gems}
  spec.description   = %q{The core gem for all Aliyun API gems. Do not use it directly.}
  spec.homepage      = "https://github.com/strikingly/aliyun-sdk-core"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.3', '>= 1.3.0'
  spec.add_development_dependency 'rake',    '~> 0.8', '>= 0.8.7'

  spec.add_dependency "ruby-hmac", "~> 0.4.0"
end
