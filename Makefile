.PHONY: test clean
.SUFFIXES:

# --- Paths / files
SOURCE.d := source/
OBJECT.d := object/
LIB.d    := library/

SOURCE := main.c gui.c sds.c
OBJECT := ${SOURCE}
OBJECT := $(subst .c,.o,${OBJECT})

GENSOURCE := markdown.tbsp.c inline.tbsp.c

vpath %.o ${OBJECT.d}
vpath %.c ${SOURCE.d}
vpath %.c ${LIB.d}
vpath %.tbsp ${SOURCE.d}
vpath %.tbsp.c ${OBJECT.d}

OUT := sternocleidomastoid

# --- Tools/Flags
ifeq (${DEBUG}, 1)
  CPPFLAGS += -DDEBUG

  CFLAGS.D += -Wall -Wextra -Wpedantic
  CFLAGS.D += -O0 -ggdb -fno-inline
  #CFLAGS.D += -fsanitize=address,undefined
  CFLAGS   += ${CFLAGS.D}
else
  CFLAGS += -O3 -flto=auto -fno-stack-protector
endif

CFLAGS += -std=c23
CPPFLAGS += -D_GNU_SOURCE -I${SOURCE.d} -I${OBJECT.d} -I${LIB.d} $$(pkg-config --cflags tcl tk x11)
LDLIBS += $$(pkg-config --libs tcl tk x11)
LDLIBS += -ltree-sitter -ltree-sitter-markdown -ltree-sitter-markdown-inline

# --- Rule Section ---
all: ${OUT}

${OUT}: ${GENSOURCE} ${OBJECT} source/graphical_library.tcl
	${LINK.c} -o $@ $(addprefix ${OBJECT.d}/,${OBJECT} ${GENSOURCE}) ${LDLIBS}

%.o: %.c
	${COMPILE.c} -o ${OBJECT.d}/$@ $<

%.tbsp.o: %.tbsp.c
	${COMPILE.c} -o ${OBJECT.d}/$@ $<

%.tbsp.c: %.tbsp
	./tbsp -o ${OBJECT.d}/$@ $? 

inline.tbsp.c: inline.tbsp
	./tbsp --prefix il -o ${OBJECT.d}/$@ $? 

clean:
	-${RM} $(or ${OBJECT.d},#)/*
	-${RM} ${OUT}
	-${RM} *.out
