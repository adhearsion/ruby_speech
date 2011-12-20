# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby_speech/version"

Gem::Specification.new do |s|
  s.name        = "ruby_speech"
  s.version     = RubySpeech::VERSION
  s.authors     = ["Ben Langfeld"]
  s.email       = ["ben@langfeld.me"]
  s.homepage    = "https://github.com/benlangfeld/ruby_speech"
  s.summary     = %q{A ruby library for TTS & ASR document preparation}
  s.description = %q{Prepare SSML and GRXML documents with ease}

  s.rubyforge_project = "ruby_speech"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency %q<niceogiri>, [">= 0.1.1"]
  s.add_runtime_dependency %q<activesupport>, [">= 3.0.7"]

  s.add_development_dependency %q<bundler>, ["~> 1.0.0"]
  s.add_development_dependency %q<rspec>, [">= 2.7.0"]
  s.add_development_dependency %q<ci_reporter>, [">= 1.6.3"]
  s.add_development_dependency %q<yard>, ["~> 0.7.0"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<mocha>, [">= 0"]
  s.add_development_dependency %q<i18n>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>, [">= 0"]
end
