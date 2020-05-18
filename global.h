#ifndef GLOBAL_H_
#define GLOBAL_H_

#include <stdint.h>

#ifdef DEBUG_
#define DBG_PRINT(...) printf(__VA_ARGS__)
#else
#define DBG_PRINT(...) do{}while(0)
#endif

#define str(s) #s
#define xstr(s) str(s)

#define ERR_IF(s) do{ \
    if(s) { \
        perror(__FILE__" - "xstr(__LINE__)); \
        return errno; \
    } \
}while(0)

#define true 1
#define false 0
typedef uint_fast8_t bool;

#endif
