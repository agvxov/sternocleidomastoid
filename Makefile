CFLAGS := -Ilibrary -D_GNU_SOURCE -std=c23 -Wall -ggdb
LIB    := $$(pkg-config --cflags --libs tcl tk) -ltree-sitter -ltree-sitter-markdown -ltree-sitter-markdown-inline

main:
	./tbsp -o main.tbsp.c main.tbsp
	./tbsp --prefix il -o inline.tbsp.c inline.tbsp
	gcc ${CFLAGS} -o main.out main.tbsp.c inline.tbsp.c library/sds.c ${LIB}
