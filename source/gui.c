#include "gui.h"

#include <stdlib.h>
#include <signal.h>
#include <errno.h>
#include <pthread.h>
#include <tcl.h>
#include <tk.h>
#include <X11/Xlib.h>

extern const char * script_buffer;

#define TCL_ARGS \
    [[maybe_unused]] ClientData clientData, \
    [[maybe_unused]] Tcl_Interp *interp, \
    [[maybe_unused]] int argc, \
    [[maybe_unused]] const char **argv
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

    Display * display = Tk_Display(Tk_MainWindow(interp));
    XReparentWindow(display, child, parent, 0, 0);
    XMapWindow(display, child);

    // XXX magic numbers instead of proper sizing
    XMoveResizeWindow(display, child, 0, 0, 400, 400);

    XFlush(display);

    return TCL_OK;
}

int Tcl_is_process_alive(TCL_ARGS) {
    if (argc != 2) {
        Tcl_WrongNumArgs(interp, 1, (Tcl_Obj*const*)argv, "pid");
        return TCL_ERROR;
    }

    char *endptr = NULL;
    long pid = strtol(argv[1], &endptr, 10);
    if (!argv[1][0] || *endptr != '\0' || pid <= 0) {
        Tcl_SetResult(interp, "invalid PID", TCL_STATIC);
        return TCL_ERROR;
    }

    int alive = (kill((pid_t)pid, 0) == 0 || errno == EPERM);

    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(alive));
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
    TCL_EASY_CREATE_COMMAND(is_process_alive);

    int result = Tcl_Eval(interp, script_buffer);
    if (result == TCL_ERROR) {
        fprintf(stderr, "Error: %s\n", Tcl_GetStringResult(interp));
        fprintf(stderr, "%s\n", Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY));
        fprintf(stderr, "Line: %d\n", Tcl_GetErrorLine(interp));
        exit(1);
    }

    Tk_MainLoop();
}
