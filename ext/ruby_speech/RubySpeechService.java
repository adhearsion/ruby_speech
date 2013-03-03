package com.benlangfeld.ruby_speech;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.RubyObject;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.load.BasicLibraryService;

public class RubySpeechService implements BasicLibraryService {
  public boolean basicLoad(Ruby ruby) {
    RubyModule ruby_speech = ruby.defineModule("RubySpeech");
    RubyModule grxml = ruby_speech.defineModuleUnder("GRXML");
    RubyClass matcher = grxml.defineClassUnder("Matcher", ruby.getObject(), new ObjectAllocator() {
      public IRubyObject allocate(Ruby runtime, RubyClass rubyClass) {
        return new RubySpeechGRXMLMatcher(runtime, rubyClass);
      }
    });
    matcher.defineAnnotatedMethods(RubySpeechGRXMLMatcher.class);
    return true;
  }
}
