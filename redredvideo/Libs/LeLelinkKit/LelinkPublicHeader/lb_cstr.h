#ifndef _CSTR_H_
#define _CSTR_H_

/* A general-purpose string "class" for C */

#if     !defined(P)
#ifdef  __STDC__
#define P(x)    x
#else
#define P(x)    ()
#endif
#endif

/*	For building dynamic link libraries under windows, windows NT 
 *	using MSVC1.5 or MSVC2.0
 */

#ifndef _DLLDECL
#define _DLLDECL

#ifdef MSVC15	/* MSVC1.5 support for 16 bit apps */
#define _MSVC15EXPORT _export
#define _MSVC20EXPORT
#define _DLLAPI _export _pascal
#define _CDECL
#define _TYPE(a) a _MSVC15EXPORT
#define DLLEXPORT 1

#elif defined(MSVC20) || (defined(_USRDLL) && defined(SRP_EXPORTS))
#define _MSVC15EXPORT
#define _MSVC20EXPORT _declspec(dllexport)
#define _DLLAPI
#define _CDECL
#define _TYPE(a) _MSVC20EXPORT a
#define DLLEXPORT 1

#else			/* Default, non-dll.  Use this for Unix or DOS */
#define _MSVC15DEXPORT
#define _MSVC20EXPORT
#define _DLLAPI
#if defined(WINDOWS) || defined(WIN32)
#define _CDECL _cdecl
#else
#define _CDECL
#endif
#define _TYPE(a) a _CDECL
#endif
#endif /* _DLLDECL */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/* Arguments to allocator methods ordered this way for compatibility */
typedef struct cstr_alloc_st_lb {
#ifdef WIN32
  void * (_CDECL * alloc)(size_t n, void * heap);
#else
  void * (_CDECL * alloc)(int n, void * heap);
#endif
  void (_CDECL * free)(void * p, void * heap);
  void * heap;
} cstr_allocator_lb;

typedef struct cstr_st_lb {
  char * data;	/* Okay to access data and length fields directly */
  int length;
  int cap;
  int ref;	/* Simple reference counter */
  cstr_allocator_lb * allocator;
} cstr_lb;

_TYPE( void ) cstr_set_allocator_lb P((cstr_allocator_lb * alloc));

_TYPE( cstr_lb * ) cstr_new_lb P((void));
_TYPE( cstr_lb * ) cstr_new_alloc_lb P((cstr_allocator_lb * alloc));
_TYPE( cstr_lb * ) cstr_dup_lb P((const cstr_lb * str));
_TYPE( cstr_lb * ) cstr_dup_alloc_lb P((const cstr_lb * str, cstr_allocator_lb * alloc));
_TYPE( cstr_lb * ) cstr_create_lb P((const char * s));
_TYPE( cstr_lb * ) cstr_createn_lb P((const char * s, int len));

_TYPE( void ) cstr_free_lb P((cstr_lb * str));
_TYPE( void ) cstr_clear_free_lb P((cstr_lb * str));
_TYPE( void ) cstr_use_lb P((cstr_lb * str));
_TYPE( void ) cstr_empty_lb P((cstr_lb * str));
_TYPE( int ) cstr_copy_lb P((cstr_lb * dst, const cstr_lb * src));
_TYPE( int ) cstr_set_lb P((cstr_lb * str, const char * s));
_TYPE( int ) cstr_setn_lb P((cstr_lb * str, const char * s, int len));
_TYPE( int ) cstr_set_length_lb P((cstr_lb * str, int len));
_TYPE( int ) cstr_append_lb P((cstr_lb * str, const char * s));
_TYPE( int ) cstr_appendn_lb P((cstr_lb * str, const char * s, int len));
_TYPE( int ) cstr_append_str_lb P((cstr_lb * dst, const cstr_lb * src));

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _CSTR_H_ */
