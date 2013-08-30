# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'midpay/alipay/version'

Gem::Specification.new do |spec|
  spec.name          = "midpay_alipay"
  spec.version       = Midpay::Alipay::VERSION
  spec.authors       = ["xixilive"]
  spec.email         = ["xixilive@gmail.com"]
  spec.description   = %q{Payment strategy for Alipay(https://alipay.com) base on Midpay Middleware.}
  spec.summary       = %q{Payment strategy for Alipay(https://alipay.com) base on Midpay Middleware.}
  spec.homepage      = "https://github.com/xixilive/midpay_alipay"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "midpay"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
