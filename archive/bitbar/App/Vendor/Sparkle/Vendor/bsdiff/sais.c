/*
 * sais.c for sais-lite
 * Copyright (c) 2008-2010 Yuta Mori All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#include <assert.h>
#include <stdlib.h>
#include "sais.h"

#ifndef UCHAR_SIZE
# define UCHAR_SIZE 256
#endif
#ifndef MINBUCKETSIZE
# define MINBUCKETSIZE 256
#endif

#define sais_bool_type  int
#define SAIS_LMSSORT2_LIMIT 0x3fffffff

#define SAIS_MYMALLOC(_num, _type) ((_type *)malloc((_num) * sizeof(_type)))
#define SAIS_MYFREE(_ptr, _num, _type) free((_ptr))
#define chr(_a) (cs == sizeof(sais_index_type) ? ((const sais_index_type *)T)[(_a)] : ((const unsigned char *)T)[(_a)])

/* find the start or end of each bucket */
static
void
getCounts(const void *T, sais_index_type *C, sais_index_type n, sais_index_type k, int cs) {
  sais_index_type i;
  for(i = 0; i < k; ++i) { C[i] = 0; }
  for(i = 0; i < n; ++i) { ++C[chr(i)]; }
}
static
void
getBuckets(const sais_index_type *C, sais_index_type *B, sais_index_type k, sais_bool_type end) {
  sais_index_type i, sum = 0;
  if(end) { for(i = 0; i < k; ++i) { sum += C[i]; B[i] = sum; } }
  else { for(i = 0; i < k; ++i) { sum += C[i]; B[i] = sum - C[i]; } }
}

/* sort all type LMS suffixes */
static
void
LMSsort1(const void *T, sais_index_type *SA,
         sais_index_type *C, sais_index_type *B,
         sais_index_type n, sais_index_type k, int cs) {
  sais_index_type *b, i, j;
  sais_index_type c0, c1;

  /* compute SAl */
  if(C == B) { getCounts(T, C, n, k, cs); }
  getBuckets(C, B, k, 0); /* find starts of buckets */
  j = n - 1;
  b = SA + B[c1 = chr(j)];
  --j;
  *b++ = (chr(j) < c1) ? ~j : j;
  for(i = 0; i < n; ++i) {
    if(0 < (j = SA[i])) {
      assert(chr(j) >= chr(j + 1));
      if((c0 = chr(j)) != c1) { B[c1] = b - SA; b = SA + B[c1 = c0]; }
      assert(i < (b - SA));
      --j;
      *b++ = (chr(j) < c1) ? ~j : j;
      SA[i] = 0;
    } else if(j < 0) {
      SA[i] = ~j;
    }
  }
  /* compute SAs */
  if(C == B) { getCounts(T, C, n, k, cs); }
  getBuckets(C, B, k, 1); /* find ends of buckets */
  for(i = n - 1, b = SA + B[c1 = 0]; 0 <= i; --i) {
    if(0 < (j = SA[i])) {
      assert(chr(j) <= chr(j + 1));
      if((c0 = chr(j)) != c1) { B[c1] = b - SA; b = SA + B[c1 = c0]; }
      assert((b - SA) <= i);
      --j;
      *--b = (chr(j) > c1) ? ~(j + 1) : j;
      SA[i] = 0;
    }
  }
}
static
sais_index_type
LMSpostproc1(const void *T, sais_index_type *SA,
             sais_index_type n, sais_index_type m, int cs) {
  sais_index_type i, j, p, q, plen, qlen, name;
  sais_index_type c0, c1;
  sais_bool_type diff;

  /* compact all the sorted substrings into the first m items of SA
      2*m must be not larger than n (proveable) */
  assert(0 < n);
  for(i = 0; (p = SA[i]) < 0; ++i) { SA[i] = ~p; assert((i + 1) < n); }
  if(i < m) {
    for(j = i, ++i;; ++i) {
      assert(i < n);
      if((p = SA[i]) < 0) {
        SA[j++] = ~p; SA[i] = 0;
        if(j == m) { break; }
      }
    }
  }

  /* store the length of all substrings */
  i = n - 1; j = n - 1; c0 = chr(n - 1);
  do { c1 = c0; } while((0 <= --i) && ((c0 = chr(i)) >= c1));
  for(; 0 <= i;) {
    do { c1 = c0; } while((0 <= --i) && ((c0 = chr(i)) <= c1));
    if(0 <= i) {
      SA[m + ((i + 1) >> 1)] = j - i; j = i + 1;
      do { c1 = c0; } while((0 <= --i) && ((c0 = chr(i)) >= c1));
    }
  }

  /* find the lexicographic names of all substrings */
  for(i = 0, name = 0, q = n, qlen = 0; i < m; ++i) {
    p = SA[i], plen = SA[m + (p >> 1)], diff = 1;
    if((plen == qlen) && ((q + plen) < n)) {
      for(j = 0; (j < plen) && (chr(p + j) == chr(q + j)); ++j) { }
      if(j == plen) { diff = 0; }
    }
    if(diff != 0) { ++name, q = p, qlen = plen; }
    SA[m + (p >> 1)] = name;
  }

  return name;
}
static
void
LMSsort2(const void *T, sais_index_type *SA,
         sais_index_type *C, sais_index_type *B, sais_index_type *D,
         sais_index_type n, sais_index_type k, int cs) {
  sais_index_type *b, i, j, t, d;
  sais_index_type c0, c1;
  assert(C != B);

  /* compute SAl */
  getBuckets(C, B, k, 0); /* find starts of buckets */
  j = n - 1;
  b = SA + B[c1 = chr(j)];
  --j;
  t = (chr(j) < c1);
  j += n;
  *b++ = (t & 1) ? ~j : j;
  for(i = 0, d = 0; i < n; ++i) {
    if(0 < (j = SA[i])) {
      if(n <= j) { d += 1; j -= n; }
      assert(chr(j) >= chr(j + 1));
      if((c0 = chr(j)) != c1) { B[c1] = b - SA; b = SA + B[c1 = c0]; }
      assert(i < (b - SA));
      --j;
      t = c0; t = (t << 1) | (chr(j) < c1);
      if(D[t] != d) { j += n; D[t] = d; }
      *b++ = (t & 1) ? ~j : j;
      SA[i] = 0;
    } else if(j < 0) {
      SA[i] = ~j;
    }
  }
  for(i = n - 1; 0 <= i; --i) {
    if(0 < SA[i]) {
      if(SA[i] < n) {
        SA[i] += n;
        for(j = i - 1; SA[j] < n; --j) { }
        SA[j] -= n;
        i = j;
      }
    }
  }

  /* compute SAs */
  getBuckets(C, B, k, 1); /* find ends of buckets */
  for(i = n - 1, d += 1, b = SA + B[c1 = 0]; 0 <= i; --i) {
    if(0 < (j = SA[i])) {
      if(n <= j) { d += 1; j -= n; }
      assert(chr(j) <= chr(j + 1));
      if((c0 = chr(j)) != c1) { B[c1] = b - SA; b = SA + B[c1 = c0]; }
      assert((b - SA) <= i);
      --j;
      t = c0; t = (t << 1) | (chr(j) > c1);
      if(D[t] != d) { j += n; D[t] = d; }
      *--b = (t & 1) ? ~(j + 1) : j;
      SA[i] = 0;
    }
  }
}
static
sais_index_type
LMSpostproc2(sais_index_type *SA, sais_index_type n, sais_index_type m) {
  sais_index_type i, j, d, name;

  /* compact all the sorted LMS substrings into the first m items of SA */
  assert(0 < n);
  for(i = 0, name = 0; (j = SA[i]) < 0; ++i) {
    j = ~j;
    if(n <= j) { name += 1; }
    SA[i] = j;
    assert((i + 1) < n);
  }
  if(i < m) {
    for(d = i, ++i;; ++i) {
      assert(i < n);
      if((j = SA[i]) < 0) {
        j = ~j;
        if(n <= j) { name += 1; }
        SA[d++] = j; SA[i] = 0;
        if(d == m) { break; }
      }
    }
  }
  if(name < m) {
    /* store the lexicographic names */
    for(i = m - 1, d = name + 1; 0 <= i; --i) {
      if(n <= (j = SA[i])) { j -= n; --d; }
      SA[m + (j >> 1)] = d;
    }
  } else {
    /* unset flags */
    for(i = 0; i < m; ++i) {
      if(n <= (j = SA[i])) { j -= n; SA[i] = j; }
    }
  }

  return name;
}

/* compute SA and BWT */
static
void
induceSA(const void *T, sais_index_type *SA,
         sais_index_type *C, sais_index_type *B,
         sais_index_type n, sais_index_type k, int cs) {
  sais_index_type *b, i, j;
  sais_index_type c0, c1;
  /* compute SAl */
  if(C == B) { getCounts(T, C, n, k, cs); }
  getBuckets(C, B, k, 0); /* find starts of buckets */
  j = n - 1;
  b = SA + B[c1 = chr(j)];
  *b++ = ((0 < j) && (chr(j - 1) < c1)) ? ~j : j;
  for(i = 0; i < n; ++i) {
    j = SA[i], SA[i] = ~j;
    if(0 < j) {
      --j;
      assert(chr(j) >= chr(j + 1));
      if((c0 = chr(j)) != c1) { B[c1] = b - SA; b = SA + B[c1 = c0]; }
      assert(i < (b - SA));
      *b++ = ((0 < j) && (chr(j - 1) < c1)) ? ~j : j;
    }
  }
  /* compute SAs */
  if(C == B) { getCounts(T, C, n, k, cs); }
  getBuckets(C, B, k, 1); /* find ends of buckets */
  for(i = n - 1, b = SA + B[c1 = 0]; 0 <= i; --i) {
    if(0 < (j = SA[i])) {
      --j;
      assert(chr(j) <= chr(j + 1));
      if((c0 = chr(j)) != c1) { B[c1] = b - SA; b = SA + B[c1 = c0]; }
      assert((b - SA) <= i);
      *--b = ((j == 0) || (chr(j - 1) > c1)) ? ~j : j;
    } else {
      SA[i] = ~j;
    }
  }
}
static
sais_index_type
computeBWT(const void *T, sais_index_type *SA,
           sais_index_type *C, sais_index_type *B,
           sais_index_type n, sais_index_type k, int cs) {
  sais_index_type *b, i, j, pidx = -1;
  sais_index_type c0, c1;
  /* compute SAl */
  if(C == B) { getCounts(T, C, n, k, cs); }
  getBuckets(C, B, k, 0); /* find starts of buckets */
  j = n - 1;
  b = SA + B[c1 = chr(j)];
  *b++ = ((0 < j) && (chr(j - 1) < c1)) ? ~j : j;
  for(i = 0; i < n; ++i) {
    if(0 < (j = SA[i])) {
      --j;
      assert(chr(j) >= chr(j + 1));
      SA[i] = ~((sais_index_type)(c0 = chr(j)));
      if(c0 != c1) { B[c1] = b - SA; b = SA + B[c1 = c0]; }
      assert(i < (b - SA));
      *b++ = ((0 < j) && (chr(j - 1) < c1)) ? ~j : j;
    } else if(j != 0) {
      SA[i] = ~j;
    }
  }
  /* compute SAs */
  if(C == B) { getCounts(T, C, n, k, cs); }
  getBuckets(C, B, k, 1); /* find ends of buckets */
  for(i = n - 1, b = SA + B[c1 = 0]; 0 <= i; --i) {
    if(0 < (j = SA[i])) {
      --j;
      assert(chr(j) <= chr(j + 1));
      SA[i] = (c0 = chr(j));
      if(c0 != c1) { B[c1] = b - SA; b = SA + B[c1 = c0]; }
      assert((b - SA) <= i);
      *--b = ((0 < j) && (chr(j - 1) > c1)) ? ~((sais_index_type)chr(j - 1)) : j;
    } else if(j != 0) {
      SA[i] = ~j;
    } else {
      pidx = i;
    }
  }
  return pidx;
}

/* find the suffix array SA of T[0..n-1] in {0..255}^n */
static
sais_index_type
sais_main(const void *T, sais_index_type *SA,
          sais_index_type fs, sais_index_type n, sais_index_type k, int cs,
          sais_bool_type isbwt) {
  sais_index_type *C, *B, *D, *RA, *b;
  sais_index_type i, j, m, p, q, t, name, pidx = 0, newfs;
  sais_index_type c0, c1;
  unsigned int flags;

  assert((T != NULL) && (SA != NULL));
  assert((0 <= fs) && (0 < n) && (1 <= k));

  if(k <= MINBUCKETSIZE) {
    if((C = SAIS_MYMALLOC((size_t)k, sais_index_type)) == NULL) { return -2; }
    if(k <= fs) {
      B = SA + (n + fs - k);
      flags = 1;
    } else {
      if((B = SAIS_MYMALLOC((size_t)k, sais_index_type)) == NULL) { SAIS_MYFREE(C, k, sais_index_type); return -2; }
      flags = 3;
    }
  } else if(k <= fs) {
    C = SA + (n + fs - k);
    if(k <= (fs - k)) {
      B = C - k;
      flags = 0;
    } else if(k <= (MINBUCKETSIZE * 4)) {
      if((B = SAIS_MYMALLOC((size_t)k, sais_index_type)) == NULL) { return -2; }
      flags = 2;
    } else {
      B = C;
      flags = 8;
    }
  } else {
    if((C = B = SAIS_MYMALLOC((size_t)k, sais_index_type)) == NULL) { return -2; }
    flags = 4 | 8;
  }
  if((n <= SAIS_LMSSORT2_LIMIT) && (2 <= (n / k))) {
    if(flags & 1) { flags |= ((k * 2) <= (fs - k)) ? 32 : 16; }
    else if((flags == 0) && ((k * 2) <= (fs - k * 2))) { flags |= 32; }
  }

  /* stage 1: reduce the problem by at least 1/2
     sort all the LMS-substrings */
  getCounts(T, C, n, k, cs); getBuckets(C, B, k, 1); /* find ends of buckets */
  for(i = 0; i < n; ++i) { SA[i] = 0; }
  b = &t; i = n - 1; j = n; m = 0; c0 = chr(n - 1);
  do { c1 = c0; } while((0 <= --i) && ((c0 = chr(i)) >= c1));
  for(; 0 <= i;) {
    do { c1 = c0; } while((0 <= --i) && ((c0 = chr(i)) <= c1));
    if(0 <= i) {
      *b = j; b = SA + --B[c1]; j = i; ++m;
      do { c1 = c0; } while((0 <= --i) && ((c0 = chr(i)) >= c1));
    }
  }

  if(1 < m) {
    if(flags & (16 | 32)) {
      if(flags & 16) {
        if((D = SAIS_MYMALLOC((size_t)k * 2, sais_index_type)) == NULL) {
          if(flags & (1 | 4)) { SAIS_MYFREE(C, k, sais_index_type); }
          if(flags & 2) { SAIS_MYFREE(B, k, sais_index_type); }
          return -2;
        }
      } else {
        D = B - k * 2;
      }
      assert((j + 1) < n);
      ++B[chr(j + 1)];
      for(i = 0, j = 0; i < k; ++i) {
        j += C[i];
        if(B[i] != j) { assert(SA[B[i]] != 0); SA[B[i]] += n; }
        D[i] = D[i + k] = 0;
      }
      LMSsort2(T, SA, C, B, D, n, k, cs);
      name = LMSpostproc2(SA, n, m);
      if(flags & 16) { SAIS_MYFREE(D, k * 2, sais_index_type); }
    } else {
      LMSsort1(T, SA, C, B, n, k, cs);
      name = LMSpostproc1(T, SA, n, m, cs);
    }
  } else if(m == 1) {
    *b = j + 1;
    name = 1;
  } else {
    name = 0;
  }

  /* stage 2: solve the reduced problem
     recurse if names are not yet unique */
  if(name < m) {
    if(flags & 4) { SAIS_MYFREE(C, k, sais_index_type); }
    if(flags & 2) { SAIS_MYFREE(B, k, sais_index_type); }
    newfs = (n + fs) - (m * 2);
    if((flags & (1 | 4 | 8)) == 0) {
      if((k + name) <= newfs) { newfs -= k; }
      else { flags |= 8; }
    }
    assert((n >> 1) <= (newfs + m));
    RA = SA + m + newfs;
    for(i = m + (n >> 1) - 1, j = m - 1; m <= i; --i) {
      if(SA[i] != 0) {
        RA[j--] = SA[i] - 1;
      }
    }
    if(sais_main(RA, SA, newfs, m, name, sizeof(sais_index_type), 0) != 0) {
      if(flags & 1) { SAIS_MYFREE(C, k, sais_index_type); }
      return -2;
    }

    i = n - 1; j = m - 1; c0 = chr(n - 1);
    do { c1 = c0; } while((0 <= --i) && ((c0 = chr(i)) >= c1));
    for(; 0 <= i;) {
      do { c1 = c0; } while((0 <= --i) && ((c0 = chr(i)) <= c1));
      if(0 <= i) {
        RA[j--] = i + 1;
        do { c1 = c0; } while((0 <= --i) && ((c0 = chr(i)) >= c1));
      }
    }
    for(i = 0; i < m; ++i) { SA[i] = RA[SA[i]]; }
    if(flags & 4) {
      if((C = B = SAIS_MYMALLOC((size_t)k, sais_index_type)) == NULL) { return -2; }
    }
    if(flags & 2) {
      if((B = SAIS_MYMALLOC((size_t)k, sais_index_type)) == NULL) {
        if(flags & 1) { SAIS_MYFREE(C, k, sais_index_type); }
        return -2;
      }
    }
  }

  /* stage 3: induce the result for the original problem */
  if(flags & 8) { getCounts(T, C, n, k, cs); }
  /* put all left-most S characters into their buckets */
  if(1 < m) {
    getBuckets(C, B, k, 1); /* find ends of buckets */
    i = m - 1, j = n, p = SA[m - 1], c1 = chr(p);
    do {
      q = B[c0 = c1];
      while(q < j) { SA[--j] = 0; }
      do {
        SA[--j] = p;
        if(--i < 0) { break; }
        p = SA[i];
      } while((c1 = chr(p)) == c0);
    } while(0 <= i);
    while(0 < j) { SA[--j] = 0; }
  }
  if(isbwt == 0) { induceSA(T, SA, C, B, n, k, cs); }
  else { pidx = computeBWT(T, SA, C, B, n, k, cs); }
  if(flags & (1 | 4)) { SAIS_MYFREE(C, k, sais_index_type); }
  if(flags & 2) { SAIS_MYFREE(B, k, sais_index_type); }

  return pidx;
}

/*---------------------------------------------------------------------------*/

sais_index_type
sais(const unsigned char *T, sais_index_type *SA, int n) {
  if((T == NULL) || (SA == NULL) || (n < 0)) { return -1; }
  if(n <= 1) { if(n == 1) { SA[0] = 0; } return 0; }
  return sais_main(T, SA, 0, n, UCHAR_SIZE, sizeof(unsigned char), 0);
}

sais_index_type
sais_int(const int *T, sais_index_type *SA, int n, int k) {
  if((T == NULL) || (SA == NULL) || (n < 0) || (k <= 0)) { return -1; }
  if(n <= 1) { if(n == 1) { SA[0] = 0; } return 0; }
  return sais_main(T, SA, 0, n, k, sizeof(int), 0);
}

sais_index_type
sais_bwt(const unsigned char *T, unsigned char *U, sais_index_type *A, int n) {
  int i;
  sais_index_type pidx;
  if((T == NULL) || (U == NULL) || (A == NULL) || (n < 0)) { return -1; }
  if(n <= 1) { if(n == 1) { U[0] = T[0]; } return n; }
  pidx = sais_main(T, A, 0, n, UCHAR_SIZE, sizeof(unsigned char), 1);
  if(pidx < 0) { return pidx; }
  U[0] = T[n - 1];
  for(i = 0; i < pidx; ++i) { U[i + 1] = (unsigned char)A[i]; }
  for(i += 1; i < n; ++i) { U[i] = (unsigned char)A[i]; }
  pidx += 1;
  return pidx;
}

sais_index_type
sais_int_bwt(const sais_index_type *T, sais_index_type *U, sais_index_type *A, int n, int k) {
  int i;
  sais_index_type pidx;
  if((T == NULL) || (U == NULL) || (A == NULL) || (n < 0) || (k <= 0)) { return -1; }
  if(n <= 1) { if(n == 1) { U[0] = T[0]; } return n; }
  pidx = sais_main(T, A, 0, n, k, sizeof(int), 1);
  if(pidx < 0) { return pidx; }
  U[0] = T[n - 1];
  for(i = 0; i < pidx; ++i) { U[i + 1] = A[i]; }
  for(i += 1; i < n; ++i) { U[i] = A[i]; }
  pidx += 1;
  return pidx;
}
