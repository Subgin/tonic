# -*- encoding: utf-8 -*-
require File.expand_path("../lib/net_http_timeout_errors/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = [ "Henrik Nyh" ]
  gem.email         = [ "henrik@nyh.se" ]
  gem.summary       = %q{Provides a list of Net::HTTP timeout errors.}
  gem.homepage      = "https://github.com/barsoom/net_http_timeout_errors"
  gem.license       = "MIT"
  gem.metadata      = { "rubygems_mfa_required" => "true" }

  gem.files         = `git ls-files`.split($\)
  gem.name          = "net_http_timeout_errors"
  gem.require_paths = [ "lib" ]
  gem.version       = NetHttpTimeoutErrors::VERSION
end
