#include "ruby.h"
#include "pcre.h"
#include <stdio.h>

static VALUE method_compile_regex(VALUE self, VALUE regex_string)
{
  int erroffset       = 0;
  const char *errptr  = "";
  int options         = 0;
  const char *regex   = StringValueCStr(regex_string);

  pcre *compiled_regex = pcre_compile(regex, options, &errptr, &erroffset, NULL);
  VALUE compiled_regex_wrapper = Data_Wrap_Struct(rb_cObject, 0, pcre_free, compiled_regex);
  rb_iv_set(self, "@regex", compiled_regex_wrapper);

  return Qnil;
}

#define MAX_INPUT_SIZE 128
#define OVECTOR_SIZE 30
#define WORKSPACE_SIZE 1024

/**
 * Check if no more digits can be added to input and match
 * @param compiled_regex the regex used in the initial match
 * @param input the input to check
 * @return true if end of match (no more input can be added)
 */
static int is_match_end(pcre *compiled_regex, const char *input)
{
  int ovector[OVECTOR_SIZE];
  int input_size = (int)strlen(input);
  char search_input[MAX_INPUT_SIZE + 2];
  const char *search_set = "0123456789#*ABCD";
  const char *search = strchr(search_set, input[input_size - 1]); /* start with last digit in input */

  /* For each digit in search_set, check if input + search_set digit is a potential match.
     If so, then this is not a match end.
   */
  if (strlen(input) > MAX_INPUT_SIZE) {
    return 0;
  }
  sprintf(search_input, "%sZ", input);
  int i;
  for (i = 0; i < 16; i++) {
    int result;
    if (!*search) {
      search = search_set;
    }
    search_input[input_size] = *search++;
    result = pcre_exec(compiled_regex, NULL, search_input, input_size + 1, 0, 0,
      ovector, sizeof(ovector) / sizeof(ovector[0]));
    if (result > 0) return 0;
  }
  return 1;
}

static VALUE method_find_match(VALUE self, VALUE buffer)
{
  VALUE RubySpeech  = rb_const_get(rb_cObject, rb_intern("RubySpeech"));
  VALUE GRXML       = rb_const_get(RubySpeech, rb_intern("GRXML"));
  VALUE NoMatch     = rb_const_get(GRXML, rb_intern("NoMatch"));
  pcre *compiled_regex;
  int result = 0;
  int ovector[OVECTOR_SIZE];
  int workspace[WORKSPACE_SIZE];
  char *input = StringValueCStr(buffer);

  Data_Get_Struct(rb_iv_get(self, "@regex"), pcre, compiled_regex);

  if (!compiled_regex) {
    return rb_class_new_instance(0, NULL, NoMatch);
  }

  result = pcre_dfa_exec(compiled_regex, NULL, input, (int)strlen(input), 0, PCRE_PARTIAL,
    ovector, sizeof(ovector) / sizeof(ovector[0]),
    workspace, sizeof(workspace) / sizeof(workspace[0]));

  if (result > 0) {
    if (is_match_end(compiled_regex, input)) {
      return rb_funcall(self, rb_intern("match_for_buffer"), 2, buffer, Qtrue);
    }
    return rb_funcall(self, rb_intern("match_for_buffer"), 1, buffer);
  }
  if (result == PCRE_ERROR_PARTIAL) {
    VALUE PotentialMatch = rb_const_get(GRXML, rb_intern("PotentialMatch"));
    return rb_class_new_instance(0, NULL, PotentialMatch);
  }
  return rb_class_new_instance(0, NULL, NoMatch);
}

void Init_ruby_speech()
{
  VALUE RubySpeech  = rb_define_module("RubySpeech");
  VALUE GRXML       = rb_define_module_under(RubySpeech, "GRXML");
  VALUE Matcher     = rb_define_class_under(GRXML, "Matcher", rb_cObject);

  rb_define_method(Matcher, "find_match", method_find_match, 1);
  rb_define_method(Matcher, "compile_regex", method_compile_regex, 1);
}
