$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'translator_proxy'
require 'vcr'
require 'rack/test'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end
