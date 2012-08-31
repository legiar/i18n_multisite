# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "i18n_multisite/version"

Gem::Specification.new do |s|
  s.name            = "i18n_multisite"
  s.version         = I18nMultisite::VERSION

  s.authors         = ["Mikhail Mikhaliov"]
  s.email           = ["legiar@gmail.com"]
  s.description     = "Support namespaces in I18n Simple backend"
  s.summary         = "Support namespaces in I18n Simple backend"
  s.homepage        = "http://github.com/legiar/i18n_multisite"
  s.licenses        = ["MIT"]

  s.files           = `git ls-files`.split($\)
  s.test_files      = s.files.grep(%r{^(test|spec|features)/})

  s.add_dependency              "rails",        ">= 3"
  s.add_development_dependency  "rspec",        ">= 2.0.0"
  s.add_development_dependency  "rspec-rails",  ">= 2.0.0"
end

