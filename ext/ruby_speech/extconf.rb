require 'mkmf'

$LIBS << " -lpcre"

abort "-----\n#{lib} is missing.\n-----" unless find_header('pcre.h')

create_makefile 'ruby_speech'
