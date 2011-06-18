# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby_speech/version"

Gem::Specification.new do |s|
  s.name        = "ruby_speech"
  s.version     = RubySpeech::VERSION
  s.authors     = ["Ben Langfeld"]
  s.email       = ["ben@langfeld.me"]
  s.homepage    = "https://github.com/mojolingo/ruby_speech"
  s.summary     = %q{A ruby library for TTS & ASR document preparation}
  s.description = %q{Prepare SSML and GRXML documents with ease}

  s.rubyforge_project = "ruby_speech"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
