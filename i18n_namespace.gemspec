# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "i18n_namespace"

Gem::Specification.new do |s|
  s.name            = "i18n_namespace"
  s.version         = I18nNamespace::VERSION

  s.authors = ["Matthias Zirnstein", "Mikhail Mikhaliov"]
  s.email = ["matthias.zirnstein@googlemail.com", "legiar@gmail.com"]
  s.description     = "I18n key injection with fallback functionality"
  s.summary         = "I18n key injection"
  s.homepage        = "http://github.com/avarteqgmbh/i18n_namespace"
  s.licenses        = ["MIT"]

  s.files           = `git ls-files`.split($\)
  s.test_files      = s.files.grep(%r{^(test|spec|features)/})

  s.add_dependency              "rails",        ">= 3"
  s.add_development_dependency  "rspec",        ">= 2.0.0"
  s.add_development_dependency  "rspec-rails",  ">= 2.0.0"
end

