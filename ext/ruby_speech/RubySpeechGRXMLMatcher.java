package com.benlangfeld.ruby_speech;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.RubyObject;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.Visibility;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.javasupport.util.RuntimeHelpers;

import java.util.regex.*;

@JRubyClass(name="RubySpeech::GRXML::Matcher")
public class RubySpeechGRXMLMatcher extends RubyObject {

  public RubySpeechGRXMLMatcher(final Ruby runtime, RubyClass rubyClass) {
    super(runtime, rubyClass);
  }

  @JRubyMethod(visibility=Visibility.PRIVATE)
  public IRubyObject check_potential_match(ThreadContext context, IRubyObject buffer)
  {
    Ruby runtime = context.getRuntime();

    IRubyObject regex = getInstanceVariable("@regex");

    Pattern p = Pattern.compile(regex.toString());
    Matcher m = p.matcher(buffer.toString());

    if (m.matches()) {
    } else if (m.hitEnd()) {
      RubyModule potential_match = runtime.getClassFromPath("RubySpeech::GRXML::PotentialMatch");
      return RuntimeHelpers.invoke(context, potential_match, "new");
    }
    return runtime.getNil();
  }

}
