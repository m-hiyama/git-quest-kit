# -*- coding: utf-8-unix -*-

FILES := $(shell cat FILES.txt)

git-quest-kit.shar : $(FILES)
	sh shar.sh $(FILES) > $@

help.tmp : git-inspect-functions.nohelp.sh
	grep -v '#%' $< | grep -e '#[^%]' | sed -e 's/#//' > $@

git-inspect-functions.sh : git-inspect-functions.nohelp.sh help.tmp
	echo "G_HELP_MSG='" > MSG-BEGIN.tmp
	echo "'" > MSG-END.tmp
	cat git-inspect-functions.nohelp.sh MSG-BEGIN.tmp help.tmp MSG-END.tmp > $@
