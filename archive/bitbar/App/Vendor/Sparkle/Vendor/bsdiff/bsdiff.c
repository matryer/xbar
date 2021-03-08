/*-
 * Copyright 2003 - 2005 Colin Percival
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
__FBSDID("$FreeBSD: src/usr.bin/bsdiff/bsdiff/bsdiff.c, v 1.1 2005/08/06 01:59:05 cperciva Exp $");
#endif

#include <sys/types.h>
#include "sais.h"

#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "bscommon.h"

#define MIN(x, y) (((x)<(y)) ? (x) : (y))

/* matchlen(old, oldsize, new, newsize)
 *
 * Returns the length of the longest common prefix between 'old' and 'new'. */
static off_t matchlen(u_char *old, off_t oldsize, u_char *new, off_t newsize)
{
    off_t i;

    for (i = 0; (i < oldsize) && (i < newsize); i++)
    {
        if (old[i] != new[i])
            break;
    }

    return i;
}

/* search(I, old, oldsize, new, newsize, st, en, pos)
 *
 * Searches for the longest prefix of 'new' that occurs in 'old', stores its
 * offset in '*pos', and returns its length. 'I' should be the suffix sort of
 * 'old', and 'st' and 'en' are the lowest and highest indices in the suffix
 * sort to consider. If you're searching all suffixes, 'st = 0' and 'en =
 * oldsize - 1'. */
static off_t search(off_t *I, u_char *old, off_t oldsize,
        u_char *new, off_t newsize, off_t st, off_t en, off_t *pos)
{
    off_t x, y;

    if (en - st < 2) {
        x = matchlen(old + I[st], oldsize - I[st], new, newsize);
        y = matchlen(old + I[en], oldsize - I[en], new, newsize);

        if (x > y) {
            *pos = I[st];
            return x;
        } else {
            *pos = I[en];
            return y;
        }
    }

    x = st + (en - st)/2;
    if (memcmp(old + I[x], new, (size_t)(MIN(oldsize - I[x], newsize))) < 0) {
        return search(I, old, oldsize, new, newsize, x, en, pos);
    } else {
        return search(I, old, oldsize, new, newsize, st, x, pos);
    };
}

/* offtout(x, buf)
 * 
 * Writes the off_t 'x' portably to the array 'buf'. */
static void offtout(off_t x, u_char *buf)
{
    off_t y;

    if (x < 0)
        y = -x;
    else
        y = x;

    buf[0] = (u_char)(y % 256);
    y -= buf[0];
    y = y/256; buf[1] = (u_char)(y%256); y -= buf[1];
    y = y/256; buf[2] = (u_char)(y%256); y -= buf[2];
    y = y/256; buf[3] = (u_char)(y%256); y -= buf[3];
    y = y/256; buf[4] = (u_char)(y%256); y -= buf[4];
    y = y/256; buf[5] = (u_char)(y%256); y -= buf[5];
    y = y/256; buf[6] = (u_char)(y%256); y -= buf[6];
    y = y/256; buf[7] = (u_char)(y%256);

    if (x < 0)
        buf[7] |= 0x80;
}

int bsdiff(int argc, char *argv[]); // Added by AMM: suppresses a warning about the following not having a prototype.

int bsdiff(int argc, char *argv[])
{
    u_char *old = NULL,*new = NULL;           /* contents of old, new files */
    off_t oldsize = 0, newsize = 0;     /* length of old, new files */
    off_t *I = NULL,*V = NULL;                /* arrays used for suffix sort; I is ordering */
    off_t scan = 0;                 /* position of current match in old file */
    off_t pos = 0;              /* position of current match in new file */
    off_t len = 0;                  /* length of current match */
    off_t lastscan = 0;             /* position of previous match in old file */
    off_t lastpos = 0;              /* position of previous match in new file */
    off_t lastoffset = 0;           /* lastpos - lastscan */
    off_t oldscore = 0, scsc = 0;       /* temp variables in match search */
    off_t s = 0, Sf = 0, lenf = 0, Sb = 0, lenb = 0;    /* temp vars in match extension */
    off_t overlap = 0, Ss = 0, lens = 0;
    off_t i = 0;
    off_t dblen = 0, eblen = 0;         /* length of diff, extra sections */
    u_char *db = NULL,*eb = NULL;             /* contents of diff, extra sections */
    u_char buf[8] = {0};
    u_char header[32] = {0};
    FILE * pf = NULL;
    int exitstatus = -1;

    if (argc != 4) {
        warnx("usage: %s oldfile newfile patchfile\n", argv[0]);
        goto cleanup;
    }

    old = readfile(argv[1], &oldsize);
    if (old == NULL) {
        warn("old file error: %s", argv[1]);
        goto cleanup;
    }

    if (((I = malloc(((size_t)oldsize + 1) * sizeof(off_t))) == NULL) ||
        ((V = malloc(((size_t)oldsize + 1) * sizeof(off_t))) == NULL)) {
        warn("Failed to allocate memory for I or V");
        goto cleanup;
    }

    /* Do a suffix sort on the old file. */
    I[0] = oldsize;
    sais(old, I+1, (int)oldsize);

    free(V);
    V = NULL;
    
    new = readfile(argv[2], &newsize);
    if (new == NULL) {
        warn("new file error: %s", argv[2]);
        goto cleanup;
    }

    if (((db = malloc((size_t)newsize + 1)) == NULL) ||
        ((eb = malloc((size_t)newsize + 1)) == NULL)) {
        warn("Failed to allocate memory for db or eb");
        goto cleanup;
    }
    dblen = 0;
    eblen = 0;

    /* Create the patch file */
    if ((pf = fopen(argv[3], "w")) == NULL) {
        warn("%s", argv[3]);
        goto cleanup;
    }

    /* Header is
        0    8     "BSDIFN40"
        8    8    length of ctrl block
        16    8    length of diff block
        24    8    length of new file */
    /* File is
        0    32    Header
        32    ??    ctrl block
        ??    ??    diff block
        ??    ??    extra block */
    memcpy(header, "BSDIFN40", 8);
    offtout(0, header + 8);
    offtout(0, header + 16);
    offtout(newsize, header + 24);
    if (fwrite(header, 32, 1, pf) != 1) {
        warn("fwrite(%s)", argv[3]);
        goto cleanup;
    }

    /* Compute the differences, writing ctrl as we go */
    scan = 0;
    len = 0;
    lastscan = 0;
    lastpos = 0;
    lastoffset = 0;
    while (scan < newsize) {
        oldscore = 0;

        for (scsc = scan += len; scan < newsize; scan++) {
            /* 'oldscore' is the number of characters that match between the
             * substrings 'old[lastoffset + scan:lastoffset + scsc]' and
             * 'new[scan:scsc]'. */
            len = search(I, old, oldsize, new + scan, newsize - scan,
                    0, oldsize, &pos);

            /* If this match extends further than the last one, add any new
             * matching characters to 'oldscore'. */
            for (; scsc < scan + len; scsc++) {
                if ((scsc + lastoffset < oldsize) &&
                    (old[scsc + lastoffset] == new[scsc]))
                    oldscore++;
            }

            /* Choose this as our match if it contains more than eight
             * characters that would be wrong if matched with a forward
             * extension of the previous match instead. */
            if (((len == oldscore) && (len != 0)) || 
                (len > oldscore + 8))
                break;

            /* Since we're advancing 'scan' by 1, remove the character under it
             * from 'oldscore' if it matches. */
            if ((scan + lastoffset < oldsize) &&
                (old[scan + lastoffset] == new[scan]))
                oldscore--;
        }

        /* Skip this section if we found an exact match that would be
         * better serviced by a forward extension of the previous match. */
        if ((len != oldscore) || (scan == newsize)) {
            /* Figure out how far forward the previous match should be
             * extended... */
            s = 0;
            Sf = 0;
            lenf = 0;
            for (i = 0; (lastscan + i < scan) && (lastpos + i < oldsize);) {
                if (old[lastpos + i] == new[lastscan + i])
                    s++;
                i++;
                if (s * 2 - i > Sf * 2 - lenf) {
                    Sf = s;
                    lenf = i;
                }
            }

            /* ... and how far backwards the next match should be extended. */
            lenb = 0;
            if (scan < newsize) {
                s = 0;
                Sb = 0;
                for (i = 1; (scan >= lastscan + i) && (pos >= i); i++) {
                    if (old[pos - i] == new[scan - i])
                        s++;
                    if (s * 2 - i > Sb * 2 - lenb) {
                        Sb = s;
                        lenb = i;
                    }
                }
            }

            /* If there is an overlap between the extensions, find the best
             * dividing point in the middle and reset 'lenf' and 'lenb'
             * accordingly. */
            if (lastscan + lenf > scan - lenb) {
                overlap = (lastscan + lenf) - (scan - lenb);
                s = 0;
                Ss = 0;
                lens = 0;
                for (i = 0; i < overlap; i++) {
                    if (new[lastscan + lenf - overlap + i] ==
                        old[lastpos + lenf - overlap + i])
                        s++;
                    if (new[scan - lenb + i] == old[pos - lenb + i])
                        s--;
                    if (s > Ss) {
                        Ss = s;
                        lens = i + 1;
                    }
                }

                lenf += lens - overlap;
                lenb -= lens;
            }

            /* Write the diff data for the last match to the diff section... */
            for (i = 0; i < lenf; i++)
                db[dblen + i] = new[lastscan + i] - old[lastpos + i];
            /* ... and, if there's a gap between the extensions just
             * calculated, write the data in that gap to the extra section. */
            for (i = 0; i< (scan - lenb) - (lastscan + lenf); i++)
                eb[eblen + i] = new[lastscan + lenf + i];

            /* Update the diff and extra section lengths accordingly. */
            dblen += lenf;
            eblen += (scan - lenb) - (lastscan + lenf);

            /* Write the following triple of integers to the control section:
             *  - length of the diff
             *  - length of the extra section
             *  - offset between the end of the diff and the start of the next
             *      diff, in the old file
             */
            offtout(lenf, buf);
            if (fwrite(buf, 8, 1, pf) != 1) {
                warnx("fwrite");
                goto cleanup;
            }

            offtout((scan - lenb) - (lastscan + lenf), buf);
            if (fwrite(buf, 8, 1, pf) != 1) {
                warn("fwrite");
                goto cleanup;
            }

            offtout((pos - lenb) - (lastpos + lenf), buf);
            if (fwrite(buf, 8, 1, pf) != 1) {
                warn("fwrite");
                goto cleanup;
            }

            /* Update the variables describing the last match. Note that
             * 'lastscan' is set to the start of the current match _after_ the
             * backwards extension; the data in that extension will be written
             * in the next pass. */
            lastscan = scan - lenb;
            lastpos = pos - lenb;
            lastoffset = pos - scan;
        }
    }

    /* Compute size of compressed ctrl data */
    if ((len = ftello(pf)) == -1) {
        warn("ftello");
        goto cleanup;
    }
    offtout(len - 32, header + 8);

    /* Write diff data */
    if (dblen && fwrite(db, (size_t)dblen, 1, pf) != 1) {
        warn("fwrite");
        goto cleanup;
    }

    /* Compute size of compressed diff data */
    if ((newsize = ftello(pf)) == -1) {
        warn("ftello");
        goto cleanup;
    }
    offtout(newsize - len, header + 16);

    /* Write extra data */
    if (eblen && fwrite(eb, (size_t)eblen, 1, pf) != 1) {
        warn("fwrite");
        goto cleanup;
    }

    /* Seek to the beginning, write the header, and close the file */
    if (fseeko(pf, 0, SEEK_SET)) {
        warn("fseeko");
        goto cleanup;
    }
    if (fwrite(header, 32, 1, pf) != 1) {
        warn("fwrite(%s)", argv[3]);
        goto cleanup;
    }
    if (fclose(pf)) {
        warn("fclose");
        pf = NULL;
        goto cleanup;
    }
    pf = NULL;
    
    exitstatus = 0;
cleanup:

    if (pf != NULL) {
        fclose(pf);
    }
    
    /* Free the memory we used */
    free(db);
    free(eb);
    free(I);
    free(V);
    free(old);
    free(new);

    return exitstatus;
}
