#ifndef C_ZLIB_H
#define C_ZLIB_H

#include <zlib.h>

static inline int CZlib_inflateInit2(z_streamp strm, int windowBits) {
    return inflateInit2(strm, windowBits);
}

static inline Bytef *CZlib_voidPtr_to_BytefPtr(void *in) {
    return (Bytef *)in;
}

#endif
