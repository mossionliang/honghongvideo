/*
 * Copyright (c) 1997-2007  The Stanford SRP_lb Authentication Project
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
#ifndef _SRP_H_
#define _SRP_H_

#include "lb_cstr.h"
#include "lb_srp_aux.h"

#ifdef __cplusplus
extern "C" {
#endif

/* SRP_lb library version identification */
#define SRP_VERSION_MAJOR 2
#define SRP_VERSION_MINOR 0
#define SRP_VERSION_PATCHLEVEL 1

typedef int SRP_RESULT_lb;
/* Returned codes for SRP_lb API functions */
#define SRP_OK(v) ((v) == SRP_SUCCESS)
#define SRP_SUCCESS 0
#define SRP_ERROR -1

/* Set the minimum number of bits acceptable in an SRP_lb modulus */
#define SRP_DEFAULT_MIN_BITS 512
_TYPE( SRP_RESULT_lb ) SRP_set_modulus_min_bits_lb P((int minbits));
_TYPE( int ) SRP_get_modulus_min_bits_lb P((void));

/*
 * Sets the "secret size callback" function.
 * This function is called with the modulus size in bits,
 * and returns the size of the secret exponent in bits.
 * The default function always returns 256 bits.
 */
typedef int (_CDECL * SRP_SECRET_BITS_CB_lb)(int modsize);
_TYPE( SRP_RESULT_lb ) SRP_set_secret_bits_cb_lb P((SRP_SECRET_BITS_CB_lb cb));
_TYPE( int ) SRP_get_secret_bits_lb P((int modsize));

typedef struct srp_st_lb SRP_lb;
/*
 * Main SRP_lb API - SRP_lb and SRP_METHOD
 */

/* SRP_lb method definitions */
typedef struct srp_meth_st_lb {
  const char * name;

  SRP_RESULT_lb (_CDECL * init)(SRP_lb * srp);
  SRP_RESULT_lb (_CDECL * finish)(SRP_lb * srp);

  SRP_RESULT_lb (_CDECL * params)(SRP_lb * srp,
			       const unsigned char * modulus, int modlen,
			       const unsigned char * generator, int genlen,
			       const unsigned char * salt, int saltlen);
  SRP_RESULT_lb (_CDECL * auth)(SRP_lb * srp, const unsigned char * a, int alen);
  SRP_RESULT_lb (_CDECL * passwd)(SRP_lb * srp,
			       const unsigned char * pass, int passlen);
  SRP_RESULT_lb (_CDECL * genpub)(SRP_lb * srp, cstr_lb ** result);
  SRP_RESULT_lb (_CDECL * key)(SRP_lb * srp, cstr_lb ** result,
			    const unsigned char * pubkey, int pubkeylen);
  SRP_RESULT_lb (_CDECL * verify)(SRP_lb * srp,
			       const unsigned char * proof, int prooflen);
  SRP_RESULT_lb (_CDECL * respond)(SRP_lb * srp, cstr_lb ** proof);

  void * data;
} SRP_METHOD_lb;

/* Magic numbers for the SRP_lb context header */
#define SRP_MAGIC_CLIENT 12
#define SRP_MAGIC_SERVER 28

/* Flag bits for SRP_lb struct */
#define SRP_FLAG_MOD_ACCEL 0x1	/* accelerate modexp operations */
#define SRP_FLAG_LEFT_PAD 0x2	/* left-pad to length-of-N inside hashes */

/*
 * A hybrid structure that represents either client or server state.
 */
struct srp_st_lb {
  int magic;	/* To distinguish client from server (and for sanity) */

  int flags;

  cstr_lb * username;

  BigInteger_lb modulus;
  BigInteger_lb generator;
  cstr_lb * salt;

  BigInteger_lb verifier;
  BigInteger_lb password;

  BigInteger_lb pubkey;
  BigInteger_lb secret;
  BigInteger_lb u;

  BigInteger_lb key;

  cstr_lb * ex_data;

  SRP_METHOD_lb * meth;
  void * meth_data;

  BigIntegerCtx_lb bctx;	     /* to cache temporaries if available */
  BigIntegerModAccel_lb accel;  /* to accelerate modexp if available */
};

/*
 * SRP_new() creates a new SRP_lb context object -
 * the method determines which "sense" (client or server)
 * the object operates in.  SRP_free() frees it.
 * (See RFC2945 method definitions below.)
 */
_TYPE( SRP_lb * )      SRP_new_lb P((SRP_METHOD_lb * meth));
_TYPE( SRP_RESULT_lb ) SRP_free_lb P((SRP_lb * srp));

/*
 * Both client and server must call both SRP_set_username and
 * SRP_set_params, in that order, before calling anything else.
 * SRP_set_user_raw is an alternative to SRP_set_username that
 * accepts an arbitrary length-bounded octet string as input.
 */
_TYPE( SRP_RESULT_lb ) SRP_set_username_lb P((SRP_lb * srp, const char * username));
_TYPE( SRP_RESULT_lb ) SRP_set_user_raw_lb P((SRP_lb * srp, const unsigned char * user,
					int userlen));
_TYPE( SRP_RESULT_lb )
     SRP_set_params_lb P((SRP_lb * srp,
		       const unsigned char * modulus, int modlen,
		       const unsigned char * generator, int genlen,
		       const unsigned char * salt, int saltlen));

/*
 * On the client, SRP_set_authenticator, SRP_gen_exp, and
 * SRP_add_ex_data can be called in any order.
 * On the server, SRP_set_authenticator must come first,
 * followed by SRP_gen_exp and SRP_add_ex_data in either order.
 */
/*
 * The authenticator is the secret possessed by either side.
 * For the server, this is the bigendian verifier, as an octet string.
 * For the client, this is the bigendian raw secret, as an octet string.
 * The server's authenticator must be the generator raised to the power
 * of the client's raw secret modulo the common modulus for authentication
 * to succeed.
 *
 * SRP_set_auth_password computes the authenticator from a plaintext
 * password and then calls SRP_set_authenticator automatically.  This is
 * usually used on the client side, while the server usually uses
 * SRP_set_authenticator (since it doesn't know the plaintext password).
 */
_TYPE( SRP_RESULT_lb )
     SRP_set_authenticator_lb P((SRP_lb * srp, const unsigned char * a, int alen));
_TYPE( SRP_RESULT_lb )
     SRP_set_auth_password_lb P((SRP_lb * srp, const char * password));
_TYPE( SRP_RESULT_lb )
     SRP_set_auth_password_raw_lb P((SRP_lb * srp,
				  const unsigned char * password,
				  int passlen));

/*
 * SRP_gen_pub generates the random exponential residue to send
 * to the other side.  If using SRP-3/RFC2945, the server must
 * withhold its result until it receives the client's number.
 * If using SRP-6, the server can send its value immediately
 * without waiting for the client.
 * 
 * If "result" points to a NULL pointer, a new cstr_lb object will be
 * created to hold the result, and "result" will point to it.
 * If "result" points to a non-NULL cstr_lb pointer, the result will be
 * placed there.
 * If "result" itself is NULL, no result will be returned,
 * although the big integer value will still be available
 * through srp->pubkey in the SRP_lb struct.
 */
_TYPE( SRP_RESULT_lb ) SRP_gen_pub_lb P((SRP_lb * srp, cstr_lb ** result));
/*
 * Append the data to the extra data segment.  Authentication will
 * not succeed unless both sides add precisely the same data in
 * the same order.
 */
_TYPE( SRP_RESULT_lb ) SRP_add_ex_data_lb P((SRP_lb * srp, const unsigned char * data,
				       int datalen));

/*
 * SRP_compute_key must be called after the previous three methods.
 */
_TYPE( SRP_RESULT_lb ) SRP_compute_key_lb P((SRP_lb * srp, cstr_lb ** result,
				       const unsigned char * pubkey,
				       int pubkeylen));

/*
 * On the client, call SRP_respond first to get the response to send
 * to the server, and call SRP_verify to verify the server's response.
 * On the server, call SRP_verify first to verify the client's response,
 * and call SRP_respond ONLY if verification succeeds.
 *
 * It is an error to call SRP_respond with a NULL pointer.
 */
_TYPE( SRP_RESULT_lb ) SRP_verify_lb P((SRP_lb * srp,
				  const unsigned char * proof, int prooflen));
_TYPE( SRP_RESULT_lb ) SRP_respond_lb P((SRP_lb * srp, cstr_lb ** response));

/* RFC2945-style SRP_lb authentication */

#define RFC2945_KEY_LEN 40	/* length of session key (bytes) */
#define RFC2945_RESP_LEN 20	/* length of proof hashes (bytes) */

/*
 * SRP-6 and SRP-6a authentication methods.
 * SRP-6a is recommended for better resistance to 2-for-1 attacks.
 */
_TYPE( SRP_METHOD_lb * ) SRP6_client_method_lb P((void));
_TYPE( SRP_METHOD_lb * ) SRP6_server_method_lb P((void));
_TYPE( SRP_METHOD_lb * ) SRP6a_client_method_lb P((void));
_TYPE( SRP_METHOD_lb * ) SRP6a_server_method_lb P((void));

#ifdef __cplusplus
}
#endif

#endif /* _SRP_H_ */
