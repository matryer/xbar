/*
 *  bscommon.c
 *  Sparkle
 *
 *  Created by Mayur Pawashe on 5/16/16.
 */

#include "bscommon.h"
#include <stdlib.h>

u_char *readfile(const char *filename, off_t *outSize)
{
    int success = -1;
    u_char *buffer = NULL;
    
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        goto cleanup;
    }
    
    if (fseek(file, 0L, SEEK_END) != 0) {
        goto cleanup;
    }
    
    long offset = ftell(file);
    if (offset == -1) {
        goto cleanup;
    }
    
    size_t size = (size_t)offset;
    
    if (outSize != NULL) {
        *outSize = (off_t)size;
    }
    
    /* Allocate size + 1 bytes instead of newsize bytes to ensure
     that we never try to malloc(0) and get a NULL pointer */
    buffer = malloc(size + 1);
    if (buffer == NULL) {
        goto cleanup;
    }
    
    if (fseek(file, 0L, SEEK_SET) != 0) {
        goto cleanup;
    }
    
    if (fread(buffer, 1, size, file) < size) {
        goto cleanup;
    }
    
    success = 0;
cleanup:
    if (success == -1) {
        free(buffer);
        buffer = NULL;
    }
    if (file != NULL) {
        fclose(file);
    }
    
    return buffer;
}
