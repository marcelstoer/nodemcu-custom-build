#!/bin/sh

set -e

if [ "${X_U8G_FONTS}" == "" ]; then
  export X_U8G_FONTS_STRING=' '
else
  # replace ',' by newline and turn every item into '    U8G_FONT_TABLE_ENTRY(<font-name>) \' (except
  # the one on the last line which mustn't have the '\'
  export X_U8G_FONTS_STRING=$(echo $X_U8G_FONTS | tr , '\n' | perl -pe 'my $break = (eof) ? "" : "\\"; s/(.*)\n/    U8G_FONT_TABLE_ENTRY($1) $break\n/g')
fi
# inject the fonts string into u8g_config.h between '#define U8G_FONT_TABLE \\n' and '\n#undef U8G_FONT_TABLE_ENTRY'
# the 's' flag in '/sg' makes . match newlines
# Perl creates a temp file which is removed right after the manipulation
perl -e 'local $/; $_ = <>; s/(#define U8G_FONT_TABLE \\\n)(.*)(\n#undef U8G_FONT_TABLE_ENTRY)/$1$ENV{"X_U8G_FONTS_STRING"}$3/sg; print' u8g_config.h > u8g_config.h.tmp && mv u8g_config.h.tmp u8g_config.h
