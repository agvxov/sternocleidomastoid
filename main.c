#include <stdio.h>
#include <stdlib.h>
#include <slurp.h>
#include <sds.h>
#include "gui.h"

extern int tbtraverse(const char * const tbcode);

sds script_buffer;

static
void usage(void) {
    puts(
        "markdown-gui <input-file>\n"
        "  -h        : print help and exit\n"
    );
}

signed main(int argc, char * argv[]) {
    // Init
    const char * in_file = NULL;

    if (argc < 2) {
      usage_error:
        usage();
        return 1;
    }

    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-h")
        ||  !strcmp(argv[i], "--help")) {
            usage();
            return 0;
        } else {
            in_file = argv[i];
        }
    }

    if (!in_file) {
        goto usage_error;
    }

    char * in_str = slurp(in_file);

    script_buffer = sdsnew("source \"lui.tcl\"\n");

    // IoC
    tbtraverse(in_str);

    // Core
    tcl_loop();
    while (true) { usleep(50 * 1000); }

    return 0;
}
