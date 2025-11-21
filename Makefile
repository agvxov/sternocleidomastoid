CFLAGS := -Ilibrary -D_GNU_SOURCE -std=c23 -Wall -ggdb
LIB    := $$(pkg-config --cflags --libs tcl tk) -ltree-sitter -ltree-sitter-markdown -lpcre

main:
	tbsp -o main.tbsp.c main.tbsp
	gcc ${CFLAGS} -o main.out main.tbsp.c library/sds.c ${LIB}
