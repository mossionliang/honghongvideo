/*
 * Copyright (c) 1997-2007  The Stanford SRP Authentication Project
 * All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS-IS" AND WITHOUT WARRANTY OF ANY KIND, 
 * EXPRESS, IMPLIED OR OTHERWISE, INCLUDING WITHOUT LIMITATION, ANY 
 * WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  
 *
 * IN NO EVENT SHALL STANFORD BE LIABLE FOR ANY SPECIAL, INCIDENTAL,
 * INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES WHATSOEVER
 * RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER OR NOT ADVISED OF
 * THE POSSIBILITY OF DAMAGE, AND ON ANY THEORY OF LIABILITY, ARISING OUT
 * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Redistributions in source or binary form must retain an intact copy
 * of this copyright notice.
 */

#ifndef SRP_AUX_H
#define SRP_AUX_H

#include "lb_tmath.h"
#include "lb_cstr.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Some functions return a BigIntegerResult.
 * Use BigIntegerOK to test for success.
 */
#define BIG_INTEGER_SUCCESS 0
#define BIG_INTEGER_ERROR -1
#define BigIntegerOK(v) ((v) == BIG_INTEGER_SUCCESS)
typedef int BigIntegerResult_lb;

_TYPE( BigInteger_lb  ) BigIntegerFromInt_lb P((unsigned int number));
_TYPE( BigInteger_lb  ) BigIntegerFromBytes_lb P((const unsigned char * bytes,
					   int length));
#define BigIntegerByteLen_lb(X) ((BigIntegerBitLen_lb(X)+7)/8)
_TYPE( int ) BigIntegerToBytes_lb P((BigInteger_lb  src,
				  unsigned char * dest, int destlen));
_TYPE( BigIntegerResult_lb ) BigIntegerToCstr_lb P((BigInteger_lb  src, cstr_lb * dest));
_TYPE( BigIntegerResult_lb ) BigIntegerToCstrEx_lb P((BigInteger_lb  src, cstr_lb * dest, int len));
_TYPE( BigIntegerResult_lb ) BigIntegerToHex_lb P((BigInteger_lb  src,
					     char * dest, int destlen));
_TYPE( BigIntegerResult_lb ) BigIntegerToString_lb P((BigInteger_lb  src,
						char * dest, int destlen,
						unsigned int radix));
_TYPE( int ) BigIntegerBitLen_lb P((BigInteger_lb  b));
_TYPE( int ) BigIntegerCmp_lb P((BigInteger_lb  c1, BigInteger_lb  c2));
_TYPE( int ) BigIntegerCmpInt_lb P((BigInteger_lb  c1, unsigned int c2));
_TYPE( BigIntegerResult_lb ) BigIntegerLShift_lb P((BigInteger_lb  result, BigInteger_lb  x,
					      unsigned int bits));
_TYPE( BigIntegerResult_lb ) BigIntegerAdd_lb P((BigInteger_lb  result,
					   BigInteger_lb  a1, BigInteger_lb  a2));
_TYPE( BigIntegerResult_lb ) BigIntegerAddInt_lb P((BigInteger_lb  result,
					      BigInteger_lb  a1, unsigned int a2));
_TYPE( BigIntegerResult_lb ) BigIntegerSub_lb P((BigInteger_lb  result,
					   BigInteger_lb  s1, BigInteger_lb  s2));
_TYPE( BigIntegerResult_lb ) BigIntegerSubInt_lb P((BigInteger_lb  result,
					      BigInteger_lb  s1, unsigned int s2));
/* For BigIntegerMul{,Int}: result != m1, m2 */
_TYPE( BigIntegerResult_lb ) BigIntegerMul_lb P((BigInteger_lb  result, BigInteger_lb  m1,
					   BigInteger_lb  m2, BigIntegerCtx_lb ctx));
_TYPE( BigIntegerResult_lb ) BigIntegerMulInt_lb P((BigInteger_lb  result,
					      BigInteger_lb  m1, unsigned int m2,
					      BigIntegerCtx_lb ctx));
_TYPE( BigIntegerResult_lb ) BigIntegerDivInt_lb P((BigInteger_lb  result,
					      BigInteger_lb  d, unsigned int m,
					      BigIntegerCtx_lb ctx));
_TYPE( BigIntegerResult_lb ) BigIntegerMod_lb P((BigInteger_lb  result, BigInteger_lb  d,
					   BigInteger_lb  m, BigIntegerCtx_lb ctx));
_TYPE( unsigned int ) BigIntegerModInt_lb P((BigInteger_lb  d, unsigned int m,
					  BigIntegerCtx_lb ctx));
_TYPE( BigIntegerResult_lb ) BigIntegerModMul_lb P((BigInteger_lb  result,
					      BigInteger_lb  m1, BigInteger_lb  m2,
					      BigInteger_lb  m, BigIntegerCtx_lb ctx));
_TYPE( BigIntegerResult_lb ) BigIntegerModExp_lb P((BigInteger_lb  result,
					      BigInteger_lb  base, BigInteger_lb  expt,
					      BigInteger_lb  modulus,
					      BigIntegerCtx_lb ctx,
					      BigIntegerModAccel_lb accel));
_TYPE( int ) BigIntegerCheckPrime_lb P((BigInteger_lb  n, BigIntegerCtx_lb ctx));

_TYPE( BigIntegerResult_lb ) BigIntegerFree_lb P((BigInteger_lb  b));
_TYPE( BigIntegerResult_lb ) BigIntegerClearFree_lb P((BigInteger_lb  b));

_TYPE( BigIntegerCtx_lb ) BigIntegerCtxNew_lb(void);
_TYPE( BigIntegerResult_lb ) BigIntegerCtxFree_lb P((BigIntegerCtx_lb ctx));

_TYPE( BigIntegerModAccel_lb ) BigIntegerModAccelNew_lb P((BigInteger_lb  m,
						     BigIntegerCtx_lb ctx));
_TYPE( BigIntegerResult_lb ) BigIntegerModAccelFree_lb P((BigIntegerModAccel_lb accel));


/* Miscellaneous functions - formerly in t_pwd.h */
/*
 * "t_random" is a cryptographic random number generator, which is seeded
 *   from various high-entropy sources and uses a one-way hash function
 *   in a feedback configuration.
 * "t_sessionkey" is the interleaved hash used to generate session keys
 *   from a large integer.
 * "t_mgf1" is an implementation of MGF1 using SHA1 to generate session
 *   keys from large integers, and is preferred over the older
 *   interleaved hash, and is used with SRP6.
 * "t_getpass" reads a password from the terminal without echoing.
 */
_TYPE( void ) t_random_lb P((unsigned char *, unsigned));
_TYPE( unsigned char * )
  t_sessionkey_lb P((unsigned char *, unsigned char *, unsigned));
_TYPE( void ) t_mgf1_lb P((unsigned char *, unsigned,
			const unsigned char *, unsigned));

#ifdef __cplusplus
}
#endif

#endif /* SRP_AUX_H */
