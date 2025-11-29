#ifndef GLOBAL_H
#define GLOBAL_H

#include <sds.h>

#define ECHO(fmt, ...) script_buffer = sdscatprintf(script_buffer, fmt "\n" __VA_OPT__(,) __VA_ARGS__)
#define ECHOV(v)       script_buffer = sdscat(script_buffer, v)

extern sds script_buffer;

#endif
