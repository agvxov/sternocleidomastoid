#ifndef HSTACK_H
#define HSTACK_H

/* Example:
 *      #include <dictate.h>
 *      #include "hstack.h"
 *
 *      signed main(void) {
 *          hstack_t(int, 12) s;
 *          hs_init(s);
 *
 *          hs_push(s, 1);
 *          hs_push(s, 2);
 *          hs_push(s, 3);
 *          hs_push(s, 4);
 *
 *          while (hs_size(s)) {
 *              dictate(hs_pop(s), "\n");
 *          }
 *
 *          return 0;
 *      }
 *
 * Notes:
 *  + "et" stands for "empty top"
 */

#define hstack_t(type, max) struct { type a[max]; size_t et; }
#define hs_init(s)          ((s).et = 0)
#define hs_size(s)          ((s).et)
#define hs_push(s, i)       ((s).a[((s).et)++] = i)
#define hs_pop(s)           ((s).a[--((s).et)])
#define hs_top(s)           ((s).a[(s).et-1])
#define hs_A(s, i)          ((s).a[i])

#endif
