#include "gui.h"

#include <stdlib.h>
#include <pthread.h>
#include <tcl.h>
#include <tk.h>
#include <X11/Xlib.h>

extern const char * script_buffer;

#define TCL_ARGS ClientData clientData, Tcl_Interp *interp, int argc, const char **argv
#define TCL_EASY_CREATE_COMMAND(c) \
    Tcl_CreateCommand(interp, #c, Tcl_ ## c, (ClientData)NULL, (void (*)(void*))NULL);

static void tcl_run(void);

void tcl_loop(void) {
    pthread_t tcl_thread;
    pthread_create(&tcl_thread, NULL, (void* (*)(void*))tcl_run, (void*)NULL);
}

int Tcl_reparent(TCL_ARGS) {
    if (argc != 3) {
        Tcl_SetResult(interp, "Usage: reparent <child_window_id> <parent_window_id>", TCL_STATIC);
        return TCL_ERROR;
    }

    Window child  = (Window)strtoul(argv[1], NULL, 0);
    Window parent = (Window)strtoul(argv[2], NULL, 0);

    Display *dpy = Tk_Display(Tk_MainWindow(interp));
    XReparentWindow(dpy, child, parent, 0, 0);
    XMapWindow(dpy, child);
    XFlush(dpy);

    return TCL_OK;
}

static
void tcl_run(void) {
    Tcl_Interp * interp = Tcl_CreateInterp();
    if (interp == NULL) {
        fprintf(stderr, "Can't create Tcl interpreter\n");
        exit(1);
    }

    Tcl_Init(interp);
    Tk_Init(interp);

    // Disable our testing trick
    Tcl_SetVar(interp, "WRAPPED", "true", 0); 

    TCL_EASY_CREATE_COMMAND(reparent);

    puts(script_buffer);

    int result = Tcl_Eval(interp, script_buffer);
    if (result == TCL_ERROR) {
        fprintf(stderr, "Error: %s\n", Tcl_GetStringResult(interp));
        fprintf(stderr, "%s\n", Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY));
        fprintf(stderr, "Line: %d\n", Tcl_GetErrorLine(interp));
        exit(1);
    }

    Tk_MainLoop();
}
