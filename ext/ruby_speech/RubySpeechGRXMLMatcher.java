package com.adhearsion.ruby_speech;

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

  Pattern p;

  public RubySpeechGRXMLMatcher(final Ruby runtime, RubyClass rubyClass) {
    super(runtime, rubyClass);
  }

  @JRubyMethod(visibility=Visibility.PRIVATE)
  public IRubyObject compile_regex(ThreadContext context, IRubyObject regex) {
    Ruby runtime = context.getRuntime();
    p = Pattern.compile(regex.toString());
    return runtime.getNil();
  }

  @JRubyMethod(visibility=Visibility.PUBLIC)
  public IRubyObject find_match(ThreadContext context, IRubyObject buffer)
  {
    Ruby runtime = context.getRuntime();
    String string_buffer = buffer.toString();
    Matcher m = p.matcher(string_buffer);

    if (m.matches()) {
      if (is_max_match(string_buffer)) {
        return RuntimeHelpers.invoke(context, this, "match_for_buffer", buffer, runtime.getTrue());
      }
      return callMethod(context, "match_for_buffer", buffer);
    } else if (m.hitEnd()) {
      RubyModule potential_match = runtime.getClassFromPath("RubySpeech::GRXML::PotentialMatch");
      return potential_match.callMethod(context, "new");
    }
    RubyModule nomatch = runtime.getClassFromPath("RubySpeech::GRXML::NoMatch");
    return nomatch.callMethod(context, "new");
  }

  public Boolean is_max_match(String buffer)
  {
    String search_set = "0123456789#*ABCD";
    for (int i = 0; i < 16; i++) {
      String new_buffer = buffer + search_set.charAt(i);
      Matcher m = p.matcher(new_buffer);
      if (m.matches()) return false;
    }
    return true;
  }

}
