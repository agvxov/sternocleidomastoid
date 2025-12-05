CFLAGS := -Ilibrary -D_GNU_SOURCE -std=c23 -Wall -ggdb
LIB    := $$(pkg-config --cflags --libs tcl tk x11) -ltree-sitter -ltree-sitter-markdown -ltree-sitter-markdown-inline

main:
	./tbsp -o markdown.tbsp.c markdown.tbsp
	./tbsp --prefix il -o inline.tbsp.c inline.tbsp
	gcc ${CFLAGS} -o sternocleidomastoid main.c gui.c markdown.tbsp.c inline.tbsp.c library/sds.c ${LIB}

clean:
	-rm -frfr *.tbsp.c
	-rm -frfr sternocleidomastoid
	-rm -frfr *.out
