# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby_speech/version"

Gem::Specification.new do |s|
  s.name        = "ruby_speech"
  s.version     = RubySpeech::VERSION
  s.authors     = ["Ben Langfeld"]
  s.email       = ["ben@langfeld.me"]
  s.homepage    = "https://github.com/benlangfeld/ruby_speech"
  s.summary     = %q{A Ruby library for TTS & ASR document preparation}
  s.description = %q{Prepare SSML and GRXML documents with ease}

  s.license = 'MIT'

  s.rubyforge_project = "ruby_speech"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  if RUBY_PLATFORM =~ /java/
    s.platform = "java"
    s.files << "lib/ruby_speech/ruby_speech.jar"
  else
    s.extensions = ['ext/ruby_speech/extconf.rb']
  end

  s.add_runtime_dependency %q<nokogiri>, ["~> 1.6"]
  s.add_runtime_dependency %q<activesupport>, [">= 3.0.7", "< 5.0.0"]

  s.add_development_dependency %q<bundler>, [">= 1.0.0"]
  s.add_development_dependency %q<rspec>, ["~> 2.7"]
  s.add_development_dependency %q<ci_reporter>, ["~> 1.6"]
  s.add_development_dependency %q<yard>, [">= 0.7.0"]
  s.add_development_dependency %q<rake>, ["< 11.0"]
  s.add_development_dependency %q<guard>, [">= 0.9.0"]
  s.add_development_dependency %q<guard-rspec>, [">= 0"]
  s.add_development_dependency %q<listen>, ["< 3.1.0"]
  s.add_development_dependency %q<ruby_gntp>, [">= 0"]
  s.add_development_dependency %q<guard-rake>, [">= 0"]
  s.add_development_dependency %q<rake-compiler>, [">= 0"]
  s.add_development_dependency %q<coveralls>, [">= 0"]

  if RUBY_VERSION < '2.0'
    s.add_development_dependency %q<term-ansicolor>, ["< 1.3.1"]
    s.add_development_dependency %q<tins>, ["~> 1.6.0"]
  end
end
