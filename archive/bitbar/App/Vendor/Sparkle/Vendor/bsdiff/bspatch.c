/*-
 * Copyright 2003-2005 Colin Percival
 * All rights reserved
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted providing that the following conditions 
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#if 0
__FBSDID("$FreeBSD: src/usr.bin/bsdiff/bspatch/bspatch.c,v 1.1 2005/08/06 01:59:06 cperciva Exp $");
#endif

#include "bspatch.h"
#include <bzlib.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <err.h>
#include <unistd.h>
#include <fcntl.h>

#include "bscommon.h"

/* Compatibility layer for reading either the old BSDIFF40 or the new BSDIFN40
   patch formats: */

typedef void* stream_t;

typedef struct
{
    stream_t (*open)(FILE*);
    void (*close)(stream_t);
    off_t (*read)(stream_t, void*, off_t);
} io_funcs_t;

static stream_t BSDIFF40_open(FILE *f)
{
    int bzerr = 0;
    BZFILE *s = NULL;
    if ((s = BZ2_bzReadOpen(&bzerr, f, 0, 0, NULL, 0)) == NULL) {
        warnx("BZ2_bzReadOpen, bz2err = %d", bzerr);
    }
    return s;
}

static void BSDIFF40_close(stream_t s)
{
    int bzerr;
    BZ2_bzReadClose(&bzerr, (BZFILE*)s);
}

static off_t BSDIFF40_read(stream_t s, void *buf, off_t len)
{
    int bzerr = 0, lenread = 0;
    lenread = BZ2_bzRead(&bzerr, (BZFILE*)s, buf, (int)len);
    if (bzerr != BZ_OK && bzerr != BZ_STREAM_END) {
        warnx("Corrupt patch\n");
        lenread = -1;
    }
    return lenread;
}

static io_funcs_t BSDIFF40_funcs = {
    BSDIFF40_open,
    BSDIFF40_close,
    BSDIFF40_read
};


static stream_t BSDIFN40_open(FILE *f)
{
    return f;
}

static void BSDIFN40_close(stream_t __unused s)
{
}

static off_t BSDIFN40_read(stream_t s, void *buf, off_t len)
{
    return (off_t)fread(buf, 1, (size_t)len, (FILE*)s);
}

static io_funcs_t BSDIFN40_funcs = {
    BSDIFN40_open,
    BSDIFN40_close,
    BSDIFN40_read
};


#ifndef u_char
typedef unsigned char u_char;
#endif

static off_t offtin(u_char *buf)
{
    off_t y;

    y=buf[7]&0x7F;
    y=y*256;y+=buf[6];
    y=y*256;y+=buf[5];
    y=y*256;y+=buf[4];
    y=y*256;y+=buf[3];
    y=y*256;y+=buf[2];
    y=y*256;y+=buf[1];
    y=y*256;y+=buf[0];

    if(buf[7]&0x80) y=-y;

    return y;
}

int bspatch(int argc,const char * const argv[])
{
    FILE * f = NULL, * cpf = NULL, * dpf = NULL, * epf = NULL;
    stream_t cstream = NULL, dstream = NULL, estream = NULL;
    ssize_t oldsize = 0,newsize = 0;
    ssize_t bzctrllen = 0,bzdatalen = 0;
    u_char header[32] = {0},buf[8] = {0};
    u_char *old = NULL, *new = NULL;
    off_t oldpos = 0,newpos = 0;
    off_t ctrl[3] = {0};
    off_t lenread = 0;
    off_t i = 0;
    io_funcs_t * io = NULL;
    int exitstatus = -1;

    if(argc!=4) {
        warnx("usage: %s oldfile newfile patchfile\n",argv[0]);
        goto cleanup;
    }

    /* Open patch file */
    if ((f = fopen(argv[3], "r")) == NULL) {
        warn("fopen(%s)", argv[3]);
        goto cleanup;
    }

    /*
    File format:
        0   8   "BSDIFF40" (bzip2) or "BSDIFN40" (raw)
        8   8   X
        16  8   Y
        24  8   sizeof(newfile)
        32  X   bzip2(control block)
        32+X    Y   bzip2(diff block)
        32+X+Y  ??? bzip2(extra block)
    with control block a set of triples (x,y,z) meaning "add x bytes
    from oldfile to x bytes from the diff block; copy y bytes from the
    extra block; seek forwards in oldfile by z bytes".
    */

    /* Read header */
    if (fread(header, 1, 32, f) < 32) {
        if (feof(f)) {
            warnx("Corrupt patch\n");
        } else {
            warn("fread(%s)", argv[3]);
        }
        goto cleanup;
    }

    /* Check for appropriate magic */
    if (memcmp(header, "BSDIFF40", 8) == 0)
        io = &BSDIFF40_funcs;
    else if (memcmp(header, "BSDIFN40", 8) == 0)
        io = &BSDIFN40_funcs;
    else {
        warnx("Corrupt patch\n");
        goto cleanup;
    }

    /* Read lengths from header */
    bzctrllen=offtin(header+8);
    bzdatalen=offtin(header+16);
    newsize=offtin(header+24);
    if((bzctrllen<0) || (bzdatalen<0) || (newsize<0)) {
        warnx("Corrupt patch\n");
        goto cleanup;
    }

    /* Close patch file and re-open it via libbzip2 at the right places */
    if (fclose(f)) {
        warn("fclose(%s)", argv[3]);
        f = NULL;
        goto cleanup;
    }
    f = NULL;
    
    if ((cpf = fopen(argv[3], "r")) == NULL) {
        warn("fopen(%s)", argv[3]);
        goto cleanup;
    }
    if (fseeko(cpf, 32, SEEK_SET)) {
        warn("fseeko(%s, %lld)", argv[3],
            (long long)32);
        goto cleanup;
    }
    cstream = io->open(cpf);
    if (cstream == NULL) {
        warn("cstream open");
        goto cleanup;
    }
    if ((dpf = fopen(argv[3], "r")) == NULL) {
        warn("fopen(%s)", argv[3]);
        goto cleanup;
    }
    if (fseeko(dpf, 32 + bzctrllen, SEEK_SET)) {
        warn("fseeko(%s, %lld)", argv[3],
            (long long)(32 + bzctrllen));
        goto cleanup;
    }
    dstream = io->open(dpf);
    if (dstream == NULL) {
        warn("dstream open");
        goto cleanup;
    }
    if ((epf = fopen(argv[3], "r")) == NULL) {
        warn("fopen(%s)", argv[3]);
        goto cleanup;
    }
    if (fseeko(epf, 32 + bzctrllen + bzdatalen, SEEK_SET)) {
        warn("fseeko(%s, %lld)", argv[3],
            (long long)(32 + bzctrllen + bzdatalen));
        goto cleanup;
    }
    estream = io->open(epf);
    if (estream == NULL) {
        warn("estream open");
        goto cleanup;
    }
    off_t size = 0;
    old = readfile(argv[1], &size);
    if (old == NULL) {
        warn("old file: %s", argv[1]);
        goto cleanup;
    }
    
    oldsize = size;
    
    if((new=malloc((size_t)newsize+1))==NULL) {
        warn("Failed to allocate memory for new");
        goto cleanup;
    }

    oldpos=0;newpos=0;
    while(newpos<newsize) {
        /* Read control data */
        for(i=0;i<=2;i++) {
            lenread = io->read(cstream, buf, 8);
            if (lenread < 8) {
                warnx("Corrupt patch\n");
                goto cleanup;
            }
            ctrl[i]=offtin(buf);
        };

        /* Sanity-check */
        if(newpos+ctrl[0]>newsize) {
            warnx("Corrupt patch\n");
            goto cleanup;
        }

        /* Read diff string */
        lenread = io->read(dstream, new + newpos, ctrl[0]);
        if (lenread < 0 || lenread < ctrl[0]) {
            warnx("Corrupt patch\n");
            goto cleanup;
        }

        /* Add old data to diff string */
        for(i=0;i<ctrl[0];i++)
            if((oldpos+i>=0) && (oldpos+i<oldsize))
                new[newpos+i]+=old[oldpos+i];

        /* Adjust pointers */
        newpos+=ctrl[0];
        oldpos+=ctrl[0];

        /* Sanity-check */
        if(newpos+ctrl[1]>newsize) {
            warnx("Corrupt patch\n");
            goto cleanup;
        }

        /* Read extra string */
        lenread = io->read(estream, new + newpos, ctrl[1]);
        if (lenread < 0 || lenread < ctrl[1]) {
            warnx("Corrupt patch\n");
            goto cleanup;
        }

        /* Adjust pointers */
        newpos+=ctrl[1];
        oldpos+=ctrl[2];
    };

    /* Clean up the bzip2 reads */
    io->close(cstream);
    cstream = NULL;
    io->close(dstream);
    dstream = NULL;
    io->close(estream);
    estream = NULL;
    
    if (fclose(cpf) != 0) {
        warn("fclose cpf(%s)", argv[3]);
        cpf = NULL;
        goto cleanup;
    }
    cpf = NULL;
    
    if (fclose(dpf) != 0) {
        warn("fclose dpf(%s)", argv[3]);
        dpf = NULL;
        goto cleanup;
    }
    dpf = NULL;
    
    if (fclose(epf) != 0) {
        warn("fclose epf(%s)", argv[3]);
        epf = NULL;
        goto cleanup;
    }
    epf = NULL;

    /* Write the new file */
    f = fopen(argv[2], "w");
    if (f == NULL) {
        warn("failed to write new file: %s", argv[2]);
        goto cleanup;
    }
    
    if (fwrite(new, 1, (size_t)newsize, f) < (size_t)newsize) {
        warn("failed to write to new file: %s", argv[2]);
        goto cleanup;
    }
    
    if (fclose(f) != 0) {
        warn("failed to close new file: %s", argv[2]);
        f = NULL;
        goto cleanup;
    }
    f = NULL;
    
    exitstatus = 0;
cleanup:
    free(new);
    free(old);
    
    if (f != NULL) {
        fclose(f);
    }
    
    if (estream != NULL) {
        io->close(estream);
    }
    
    if (epf != NULL) {
        fclose(epf);
    }
    
    if (dstream != NULL) {
        io->close(dstream);
    }
    
    if (dpf != NULL) {
        fclose(dpf);
    }
    
    if (cstream != NULL) {
        io->close(cstream);
    }
    
    if (cpf != NULL) {
        fclose(cpf);
    }

    return exitstatus;
}
