#include "ruby.h"
#include "pcre.h"
#include <stdio.h>

static VALUE method_check_potential_match(VALUE self, VALUE buffer)
{
  int erroffset = 0;
  const char *errptr = "";
  int options = 0;
  VALUE regex_string = rb_funcall(rb_iv_get(self, "@regex"), rb_intern("to_s"), 0);
  const char *regex = StringValueCStr(regex_string);

  pcre *compiled_regex = pcre_compile(regex, options, &errptr, &erroffset, NULL);

  int result = 0;
  int ovector[30];
  int workspace[1024];
  char *input = StringValueCStr(buffer);
  result = pcre_dfa_exec(compiled_regex, NULL, input, strlen(input), 0, PCRE_PARTIAL,
    ovector, sizeof(ovector) / sizeof(ovector[0]),
    workspace, sizeof(workspace) / sizeof(workspace[0]));
  pcre_free(compiled_regex);

  if (result == PCRE_ERROR_PARTIAL) {
    VALUE RubySpeech      = rb_const_get(rb_cObject, rb_intern("RubySpeech"));
    VALUE GRXML           = rb_const_get(RubySpeech, rb_intern("GRXML"));
    VALUE PotentialMatch  = rb_const_get(GRXML, rb_intern("PotentialMatch"));

    return rb_class_new_instance(0, NULL, PotentialMatch);
  }
  return Qnil;
}

void Init_ruby_speech()
{
  VALUE RubySpeech  = rb_define_module("RubySpeech");
  VALUE GRXML       = rb_define_module_under(RubySpeech, "GRXML");
  VALUE Matcher     = rb_define_class_under(GRXML, "Matcher", rb_cObject);

  rb_define_method(Matcher, "check_potential_match", method_check_potential_match, 1);
}
