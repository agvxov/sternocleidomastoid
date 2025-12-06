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

static
void chdir_to_parent(const char * const file) {
    char mutable_file[strlen(file)+1];
    strcpy(mutable_file, file);
    char * directory_name = dirname(mutable_file);

    int e = chdir(directory_name);

    if (e == -1) { exit(3); }
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

    char * user_script = getenv("STERNOCLEIDOMASTOID_GRAPHICAL_USER_INTERFACE_SCRIPT");
    if (!in_file) { goto usage_error; }

    char * in_str = slurp(in_file);
    if (!in_str) { return 2; }

    script_buffer = sdsnew(graphical_library_script);
    if (user_script) {
        script_buffer = sdscatfmt(script_buffer, "source \"%s\"\n", user_script);
    }
    
    chdir_to_parent(in_file);

    // IoC
    tbtraverse(in_str);

  #if DEBUG
    puts(script_buffer);
  #endif

    // Core
    tcl_loop();
    while (true) { usleep(50 * 1000); }

    return 0;
}
