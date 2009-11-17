
files=`find tests/unittest -name '*.md'`

ruby -Ilib bin/marutest $files

