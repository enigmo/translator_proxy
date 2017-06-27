# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'translator_proxy/version'

Gem::Specification.new do |spec|
  spec.name          = "translator_proxy"
  spec.version       = TranslatorProxy::VERSION
  spec.authors       = ["'Taku Okawa'"]
  spec.email         = ["'taku.okawa@gmail.com'"]
  spec.summary       = %q{ruby client for 3rd party translation API}
  spec.description   = %q{provide easy access to google translate/microsoft translator}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'google-cloud-translate'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'sinatra-contrib'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
end
