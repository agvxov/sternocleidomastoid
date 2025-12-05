#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>
#include <slurp.h>
#include <sds.h>
#include "gui.h"

extern int tbtraverse(const char * const tbcode);

sds script_buffer;
const char graphical_library_script[] = {
    #embed "graphical_library.tcl"
    , '\0'
};

static
void usage(void) {
    puts(
        "sternocleidomastoid [options] <input-file>\n"
        "  -h            : print help and exit\n"
        "  --dump-script : dump embedded Tcl GUI script and exit\n"
    );
}

signed main(const int argc, char * argv[]) {
    // Init
    int e = 0;
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
        } else
        if (!strcmp(argv[i], "--dump-script")) {
            puts(graphical_library_script);
            return 0;
        } else {
            in_file = argv[i];
        }
    }

    if (!in_file) { goto usage_error; }

    char * in_str = slurp(in_file);

    if (!in_str) { return 2; }
    
    {
        char mutable_in_file[strlen(in_file)+1];
        strcpy(mutable_in_file, in_file);
        char * directory_name = dirname(mutable_in_file);
        e = chdir(directory_name);
        if (e == -1) { return 3; }
    }

    script_buffer = sdsnew(graphical_library_script);

    // IoC
    tbtraverse(in_str);

    // Core
    tcl_loop();
    while (true) { usleep(50 * 1000); }

    return 0;
}
