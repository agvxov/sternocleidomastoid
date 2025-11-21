#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <tcl.h>
#include <tk.h>
#include <slurp.h>

static
int Tcl_cGetCounter(TCL_ARGS) {
    char r[12];
    sprintf(r, "%ld", 10l);
    Tcl_SetResult(interp, r, TCL_VOLATILE);
    return TCL_OK;
}


signed main(int argc, char * argv[]) {
    if (argc < 2) { return 1; }


    return 0;
}
