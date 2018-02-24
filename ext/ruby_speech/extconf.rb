require 'mkmf'

$LIBS << " -lpcre"

unless find_header('pcre.h')
  abort "-----\nPCRE is missing. You must install it as per the README @ https://github.com/adhearsion/ruby_speech\n-----"
end

create_makefile 'ruby_speech/ruby_speech'
