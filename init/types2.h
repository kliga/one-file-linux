#ifndef _LINUX_TYPES_H
#define _LINUX_TYPES_H

#include <stdarg.h>

#define __EXPORTED_HEADERS__
//#include <uapi/linux/types.h>

//#include <asm/types.h>

#define __BITS_PER_LONG 64

#ifdef CONFIG_64BIT
#define BITS_PER_LONG 64
#else
#define BITS_PER_LONG 32
#endif /* CONFIG_64BIT */

/*
 * FIXME: The check currently breaks x86-64 build, so it's
 * temporarily disabled. Please fix x86-64 and reenable
 */
#if 0 && BITS_PER_LONG != __BITS_PER_LONG
#error Inconsistent word size. Check asm/bitsperlong.h
#endif

#ifndef BITS_PER_LONG_LONG
#define BITS_PER_LONG_LONG 64
#endif


#ifndef __ASSEMBLY__
/*
 * __xx is ok: it doesn't pollute the POSIX namespace. Use these in the
 * header files exported to user space
 */

typedef __signed__ char __s8;
typedef unsigned char __u8;

typedef __signed__ short __s16;
typedef unsigned short __u16;

typedef __signed__ int __s32;
typedef unsigned int __u32;

#ifdef __GNUC__
__extension__ typedef __signed__ long long __s64;
__extension__ typedef unsigned long long __u64;
#else
typedef __signed__ long long __s64;
typedef unsigned long long __u64;
#endif

#endif /* __ASSEMBLY__ */


#ifndef __ASSEMBLY__

typedef signed char s8;
typedef unsigned char u8;

typedef signed short s16;
typedef unsigned short u16;

typedef signed int s32;
typedef unsigned int u32;

typedef signed long long s64;
typedef unsigned long long u64;

#define S8_C(x)  x
#define U8_C(x)  x ## U
#define S16_C(x) x
#define U16_C(x) x ## U
#define S32_C(x) x
#define U32_C(x) x ## U
#define S64_C(x) x ## LL
#define U64_C(x) x ## ULL

#else /* __ASSEMBLY__ */

#define S8_C(x)  x
#define U8_C(x)  x
#define S16_C(x) x
#define U16_C(x) x
#define S32_C(x) x
#define U32_C(x) x
#define S64_C(x) x
#define U64_C(x) x

#endif /* __ASSEMBLY__ */

#ifndef __ASSEMBLY__
#ifndef	__KERNEL__
#ifndef __EXPORTED_HEADERS__
#warning "Attempt to use kernel headers from user space, see http://kernelnewbies.org/KernelHeaders"
#endif /* __EXPORTED_HEADERS__ */
#endif

//#include <linux/posix_types.h>
//#include <linux/stddef.h>


//#include <uapi/linux/stddef.h>
//#include <linux/compiler2.h>

#ifndef __ASSEMBLY__

#ifdef __CHECKER__
# define __user		__attribute__((noderef, address_space(1)))
# define __kernel	__attribute__((address_space(0)))
# define __safe		__attribute__((safe))
# define __force	__attribute__((force))
# define __nocast	__attribute__((nocast))
# define __iomem	__attribute__((noderef, address_space(2)))
# define __must_hold(x)	__attribute__((context(x,1,1)))
# define __acquires(x)	__attribute__((context(x,0,1)))
# define __releases(x)	__attribute__((context(x,1,0)))
# define __acquire(x)	__context__(x,1)
# define __release(x)	__context__(x,-1)
# define __cond_lock(x,c)	((c) ? ({ __acquire(x); 1; }) : 0)
# define __percpu	__attribute__((noderef, address_space(3)))
#ifdef CONFIG_SPARSE_RCU_POINTER
# define __rcu		__attribute__((noderef, address_space(4)))
#else
# define __rcu
#endif


#else
# define __user
# define __kernel
# define __safe
# define __force
# define __nocast
# define __iomem


# define __builtin_warning(x, y...) (1)
# define __must_hold(x)
# define __acquires(x)
# define __releases(x)
# define __acquire(x) (void)0
# define __release(x) (void)0
# define __cond_lock(x,c) (c)
# define __percpu
# define __rcu
#endif

/* Indirect macros required for expanded argument pasting, eg. __LINE__. */
#define ___PASTE(a,b) a##b
#define __PASTE(a,b) ___PASTE(a,b)

#ifdef __KERNEL__

#define GCC_VERSION (__GNUC__ * 10000 \
			+ __GNUC_MINOR__ * 100 \
			+ __GNUC_PATCHLEVEL__)


/* Optimization barrier */
/* The "volatile" is due to gcc bugs */
#define barrier() __asm__ __volatile__("": : :"memory")

/*
* This macro obfuscates arithmetic on a variable address so that gcc
* shouldn't recognize the original var, and make assumptions about it.
*
* This is needed because the C standard makes it undefined to do
* pointer arithmetic on "objects" outside their boundaries and the
* gcc optimizers assume this is the case. In particular they
* assume such arithmetic does not wrap.
*
* A miscompilation has been observed because of this on PPC.
* To work around it we hide the relationship of the pointer and the object
* using this macro.
*
* Versions of the ppc64 compiler before 4.1 had a bug where use of
* RELOC_HIDE could trash r30. The bug can be worked around by changing
* the inline assembly constraint from =g to =r, in this particular
* case either is valid.
*/
#define RELOC_HIDE(ptr, off)					\
	({ unsigned long __ptr;					\
		__asm__ ("" : "=r"(__ptr) : "0"(ptr));		\
		(typeof(ptr)) (__ptr + (off)); })

/* Make the optimizer believe the variable can be manipulated arbitrarily. */
#define OPTIMIZER_HIDE_VAR(var) __asm__ ("" : "=r" (var) : "0" (var))

#ifdef __CHECKER__
#define __must_be_array(arr) 0
#else
/* &a[0] degrades to a pointer: a different type from an array */
#define __must_be_array(a) BUILD_BUG_ON_ZERO(__same_type((a), &(a)[0]))
#endif

/*
* Force always-inline if the user requests it so via the .config,
* or if gcc is too old:
*/
#if !defined(CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING) || \
		!defined(CONFIG_OPTIMIZE_INLINING) || (__GNUC__ < 4)
# define inline		inline		__attribute__((always_inline)) notrace
# define __inline__	__inline__	__attribute__((always_inline)) notrace
# define __inline	__inline	__attribute__((always_inline)) notrace
#else
/* A lot of inline functions can cause havoc with function tracing */
# define inline		inline		notrace
# define __inline__	__inline__	notrace
# define __inline	__inline	notrace
#endif

#define __deprecated			__attribute__((deprecated))
#define __packed			__attribute__((packed))
#define __weak				__attribute__((weak))

/*
* it doesn't make sense on ARM (currently the only user of __naked) to trace
* naked functions because then mcount is called without stack and frame pointer
* being set up and there is no chance to restore the lr register to the value
* before mcount was called.
*
* The asm() bodies of naked functions often depend on standard calling conventions,
* therefore they must be noinline and noclone.  GCC 4.[56] currently fail to enforce
* this, so we must do so ourselves.  See GCC PR44290.
*/
#define __naked				__attribute__((naked)) noinline __noclone notrace

#define __noreturn			__attribute__((noreturn))

/*
* From the GCC manual:
*
* Many functions have no effects except the return value and their
* return value depends only on the parameters and/or global
* variables.  Such a function can be subject to common subexpression
* elimination and loop optimization just as an arithmetic operator
* would be.
* [...]
*/
#define __pure				__attribute__((pure))
#define __aligned(x)			__attribute__((aligned(x)))
#define __printf(a, b)			__attribute__((format(printf, a, b)))
#define __scanf(a, b)			__attribute__((format(scanf, a, b)))
#define  noinline			__attribute__((noinline))
#define __attribute_const__		__attribute__((__const__))
#define __maybe_unused			__attribute__((unused))
#define __always_unused			__attribute__((unused))

#define __gcc_header(x) #x
#define _gcc_header(x) __gcc_header(linux/compiler-gcc##x.h)
#define gcc_header(x) _gcc_header(x)

/* GCC 4.1.[01] miscompiles __weak */
#ifdef __KERNEL__
# if GCC_VERSION >= 40100 &&  GCC_VERSION <= 40101
#  error Your version of gcc miscompiles the __weak directive
# endif
#endif

#define __used			__attribute__((__used__))
#define __must_check 		__attribute__((warn_unused_result))
#define __compiler_offsetof(a,b) __builtin_offsetof(a,b)

#if GCC_VERSION >= 40100 && GCC_VERSION < 40600
# define __compiletime_object_size(obj) __builtin_object_size(obj, 0)
#endif

#if GCC_VERSION >= 40300
/* Mark functions as cold. gcc will assume any path leading to a call
	to them will be unlikely.  This means a lot of manual unlikely()s
	are unnecessary now for any paths leading to the usual suspects
	like BUG(), printk(), panic() etc. [but let's keep them for now for
	older compilers]

	Early snapshots of gcc 4.3 don't support this and we can't detect this
	in the preprocessor, but we can live with this because they're unreleased.
	Maketime probing would be overkill here.

	gcc also has a __attribute__((__hot__)) to move hot functions into
	a special section, but I don't see any sense in this right now in
	the kernel context */
#define __cold			__attribute__((__cold__))

#define __UNIQUE_ID(prefix) __PASTE(__PASTE(__UNIQUE_ID_, prefix), __COUNTER__)

#ifndef __CHECKER__
# define __compiletime_warning(message) __attribute__((warning(message)))
# define __compiletime_error(message) __attribute__((error(message)))
#endif /* __CHECKER__ */
#endif /* GCC_VERSION >= 40300 */

#if GCC_VERSION >= 40500
/*
* Mark a position in code as unreachable.  This can be used to
* suppress control flow warnings after asm blocks that transfer
* control elsewhere.
*
* Early snapshots of gcc 4.5 don't support this and we can't detect
* this in the preprocessor, but we can live with this because they're
* unreleased.  Really, we need to have autoconf for the kernel.
*/
#define unreachable() __builtin_unreachable()

/* Mark a function definition as prohibited from being cloned. */
#define __noclone	__attribute__((__noclone__))

#endif /* GCC_VERSION >= 40500 */

#if GCC_VERSION >= 40600
/*
* Tell the optimizer that something else uses this function or variable.
*/
#define __visible __attribute__((externally_visible))
#endif

/*
* GCC 'asm goto' miscompiles certain code sequences:
*
*   http://gcc.gnu.org/bugzilla/show_bug.cgi?id=58670
*
* Work it around via a compiler barrier quirk suggested by Jakub Jelinek.
* Fixed in GCC 4.8.2 and later versions.
*
* (asm goto is automatically volatile - the naming reflects this.)
*/
#define asm_volatile_goto(x...)	do { asm goto(x); asm (""); } while (0)

#ifdef CONFIG_ARCH_USE_BUILTIN_BSWAP
#if GCC_VERSION >= 40400
#define __HAVE_BUILTIN_BSWAP32__
#define __HAVE_BUILTIN_BSWAP64__
#endif
#if GCC_VERSION >= 40800 || (defined(__powerpc__) && GCC_VERSION >= 40600)
#define __HAVE_BUILTIN_BSWAP16__
#endif
#endif /* CONFIG_ARCH_USE_BUILTIN_BSWAP */


#if !defined(__noclone)
#define __noclone	/* not needed */
#endif

/*
* A trick to suppress uninitialized variable warning without generating any
* code
*/
#define uninitialized_var(x) x = x

#define __always_inline		inline __attribute__((always_inline))

#define notrace __attribute__((no_instrument_function))


/*
* Generic compiler-dependent macros required for kernel
* build go below this comment. Actual compiler/compiler version
* specific implementations come from the above header files
*/

struct ftrace_branch_data {
	const char *func;
	const char *file;
	unsigned line;
	union {
		struct {
			unsigned long correct;
			unsigned long incorrect;
		};
		struct {
			unsigned long miss;
			unsigned long hit;
		};
		unsigned long miss_hit[2];
	};
};

/*
* Note: DISABLE_BRANCH_PROFILING can be used by special lowlevel code
* to disable branch tracing on a per file basis.
*/
#if defined(CONFIG_TRACE_BRANCH_PROFILING) \
		&& !defined(DISABLE_BRANCH_PROFILING) && !defined(__CHECKER__)
void ftrace_likely_update(struct ftrace_branch_data *f, int val, int expect);

#define likely_notrace(x)	__builtin_expect(!!(x), 1)
#define unlikely_notrace(x)	__builtin_expect(!!(x), 0)

#define __branch_check__(x, expect) ({					\
			int ______r;					\
			static struct ftrace_branch_data		\
				__attribute__((__aligned__(4)))		\
				__attribute__((section("_ftrace_annotated_branch"))) \
				______f = {				\
				.func = __func__,			\
				.file = __FILE__,			\
				.line = __LINE__,			\
			};						\
			______r = likely_notrace(x);			\
			ftrace_likely_update(&______f, ______r, expect); \
			______r;					\
		})

/*
* Using __builtin_constant_p(x) to ignore cases where the return
* value is always the same.  This idea is taken from a similar patch
* written by Daniel Walker.
*/
# ifndef likely
#  define likely(x)	(__builtin_constant_p(x) ? !!(x) : __branch_check__(x, 1))
# endif
# ifndef unlikely
#  define unlikely(x)	(__builtin_constant_p(x) ? !!(x) : __branch_check__(x, 0))
# endif

#ifdef CONFIG_PROFILE_ALL_BRANCHES
/*
* "Define 'is'", Bill Clinton
* "Define 'if'", Steven Rostedt
*/
#define if(cond, ...) __trace_if( (cond , ## __VA_ARGS__) )
#define __trace_if(cond) \
	if (__builtin_constant_p((cond)) ? !!(cond) :			\
	({								\
		int ______r;						\
		static struct ftrace_branch_data			\
			__attribute__((__aligned__(4)))			\
			__attribute__((section("_ftrace_branch")))	\
			______f = {					\
				.func = __func__,			\
				.file = __FILE__,			\
				.line = __LINE__,			\
			};						\
		______r = !!(cond);					\
		______f.miss_hit[______r]++;					\
		______r;						\
	}))
#endif /* CONFIG_PROFILE_ALL_BRANCHES */

#else
# define likely(x)	__builtin_expect(!!(x), 1)
# define unlikely(x)	__builtin_expect(!!(x), 0)
#endif

/* Optimization barrier */
#ifndef barrier
# define barrier() __memory_barrier()
#endif

/* Unreachable code */
#ifndef unreachable
# define unreachable() do { } while (1)
#endif

#ifndef RELOC_HIDE
# define RELOC_HIDE(ptr, off)					\
	({ unsigned long __ptr;					\
		__ptr = (unsigned long) (ptr);				\
		(typeof(ptr)) (__ptr + (off)); })
#endif

#ifndef OPTIMIZER_HIDE_VAR
#define OPTIMIZER_HIDE_VAR(var) barrier()
#endif

/* Not-quite-unique ID. */
#ifndef __UNIQUE_ID
# define __UNIQUE_ID(prefix) __PASTE(__PASTE(__UNIQUE_ID_, prefix), __LINE__)
#endif

#endif /* __KERNEL__ */

#endif /* __ASSEMBLY__ */

#ifdef __KERNEL__
/*
* Allow us to mark functions as 'deprecated' and have gcc emit a nice
* warning for each use, in hopes of speeding the functions removal.
* Usage is:
* 		int __deprecated foo(void)
*/
#ifndef __deprecated
# define __deprecated		/* unimplemented */
#endif

#ifdef MODULE
#define __deprecated_for_modules __deprecated
#else
#define __deprecated_for_modules
#endif

#ifndef __must_check
#define __must_check
#endif

#ifndef CONFIG_ENABLE_MUST_CHECK
#undef __must_check
#define __must_check
#endif
#ifndef CONFIG_ENABLE_WARN_DEPRECATED
#undef __deprecated
#undef __deprecated_for_modules
#define __deprecated
#define __deprecated_for_modules
#endif

/*
* Allow us to avoid 'defined but not used' warnings on functions and data,
* as well as force them to be emitted to the assembly file.
*
* As of gcc 3.4, static functions that are not marked with attribute((used))
* may be elided from the assembly file.  As of gcc 3.4, static data not so
* marked will not be elided, but this may change in a future gcc version.
*
* NOTE: Because distributions shipped with a backported unit-at-a-time
* compiler in gcc 3.3, we must define __used to be __attribute__((used))
* for gcc >=3.3 instead of 3.4.
*
* In prior versions of gcc, such functions and data would be emitted, but
* would be warned about except with attribute((unused)).
*
* Mark functions that are referenced only in inline assembly as __used so
* the code is emitted even though it appears to be unreferenced.
*/
#ifndef __used
# define __used			/* unimplemented */
#endif

#ifndef __maybe_unused
# define __maybe_unused		/* unimplemented */
#endif

#ifndef __always_unused
# define __always_unused	/* unimplemented */
#endif

#ifndef noinline
#define noinline
#endif

/*
* Rather then using noinline to prevent stack consumption, use
* noinline_for_stack instead.  For documentation reasons.
*/
#define noinline_for_stack noinline

#ifndef __always_inline
#define __always_inline inline
#endif

#endif /* __KERNEL__ */

/*
* From the GCC manual:
*
* Many functions do not examine any values except their arguments,
* and have no effects except the return value.  Basically this is
* just slightly more strict class than the `pure' attribute above,
* since function is not allowed to read global memory.
*
* Note that a function that has pointer arguments and examines the
* data pointed to must _not_ be declared `const'.  Likewise, a
* function that calls a non-`const' function usually must not be
* `const'.  It does not make sense for a `const' function to return
* `void'.
*/
#ifndef __attribute_const__
# define __attribute_const__	/* unimplemented */
#endif

/*
* Tell gcc if a function is cold. The compiler will assume any path
* directly leading to the call is unlikely.
*/

#ifndef __cold
#define __cold
#endif

/* Simple shorthand for a section definition */
#ifndef __section
# define __section(S) __attribute__ ((__section__(#S)))
#endif

#ifndef __visible
#define __visible
#endif

/* Are two types/vars the same type (ignoring qualifiers)? */
#ifndef __same_type
# define __same_type(a, b) __builtin_types_compatible_p(typeof(a), typeof(b))
#endif

/* Is this type a native word size -- useful for atomic operations */
#ifndef __native_word
# define __native_word(t) (sizeof(t) == sizeof(int) || sizeof(t) == sizeof(long))
#endif

/* Compile time object size, -1 for unknown */
#ifndef __compiletime_object_size
# define __compiletime_object_size(obj) -1
#endif
#ifndef __compiletime_warning
# define __compiletime_warning(message)
#endif
#ifndef __compiletime_error
# define __compiletime_error(message)
/*
* Sparse complains of variable sized arrays due to the temporary variable in
* __compiletime_assert. Unfortunately we can't just expand it out to make
* sparse see a constant array size without breaking compiletime_assert on old
* versions of GCC (e.g. 4.2.4), so hide the array from sparse altogether.
*/
# ifndef __CHECKER__
#  define __compiletime_error_fallback(condition) \
	do { ((void)sizeof(char[1 - 2 * condition])); } while (0)
# endif
#endif
#ifndef __compiletime_error_fallback
# define __compiletime_error_fallback(condition) do { } while (0)
#endif

#define __compiletime_assert(condition, msg, prefix, suffix)		\
	do {								\
		bool __cond = !(condition);				\
		void prefix ## suffix(void) __compiletime_error(msg); \
		if (__cond)						\
			prefix ## suffix();				\
		__compiletime_error_fallback(__cond);			\
	} while (0)

#define _compiletime_assert(condition, msg, prefix, suffix) \
	__compiletime_assert(condition, msg, prefix, suffix)

/**
* compiletime_assert - break build and emit msg if condition is false
* @condition: a compile-time constant condition to check
* @msg:       a message to emit if condition is false
*
* In tradition of POSIX assert, this macro will break the build if the
* supplied condition is *false*, emitting the supplied error message if the
* compiler has support to do so.
*/
#define compiletime_assert(condition, msg) \
	_compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)

#define compiletime_assert_atomic_type(t)				\
	compiletime_assert(__native_word(t),				\
		"Need native word sized stores/loads for atomicity.")

/*
* Prevent the compiler from merging or refetching accesses.  The compiler
* is also forbidden from reordering successive instances of ACCESS_ONCE(),
* but only when the compiler is aware of some particular ordering.  One way
* to make the compiler aware of ordering is to put the two invocations of
* ACCESS_ONCE() in different C statements.
*
* This macro does absolutely -nothing- to prevent the CPU from reordering,
* merging, or refetching absolutely anything at any time.  Its main intended
* use is to mediate communication between process-level code and irq/NMI
* handlers, all running on the same CPU.
*/
#define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))

/* Ignore/forbid kprobes attach on very low level functions marked by this attribute: */
#ifdef CONFIG_KPROBES
# define __kprobes	__attribute__((__section__(".kprobes.text")))
# define nokprobe_inline	__always_inline
#else
# define __kprobes
# define nokprobe_inline	inline
#endif

#undef NULL
#define NULL ((void *)0)

enum {
	false	= 0,
	true	= 1
};

#undef offsetof
#ifdef __compiler_offsetof
#define offsetof(TYPE,MEMBER) __compiler_offsetof(TYPE,MEMBER)
#else
#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)
#endif


/*
 * This allows for 1024 file descriptors: if NR_OPEN is ever grown
 * beyond that you'll have to change this too. But 1024 fd's seem to be
 * enough even for such "real" unices like OSF/1, so hopefully this is
 * one limit that doesn't have to be changed [again].
 *
 * Note that POSIX wants the FD_CLEAR(fd,fdsetp) defines to be in
 * <sys/time.h> (and thus <linux/time.h>) - but this is a more logical
 * place for them. Solved by having dummy defines in <sys/time.h>.
 */

/*
 * This macro may have been defined in <gnu/types.h>. But we always
 * use the one here.
 */
#undef __FD_SETSIZE
#define __FD_SETSIZE	1024

typedef struct {
	unsigned long fds_bits[__FD_SETSIZE / (8 * sizeof(long))];
} __kernel_fd_set;

/* Type of a signal handler.  */
typedef void (*__kernel_sighandler_t)(int);

/* Type of a SYSV IPC key.  */
typedef int __kernel_key_t;
typedef int __kernel_mqd_t;

//#include <asm/posix_types.h>


//#include <asm/bitsperlong.h>

//#include <uapi/asm-generic/bitsperlong.h>

#ifndef __BITS_PER_LONG
#define __BITS_PER_LONG 32
#endif



#ifdef CONFIG_64BIT
#define BITS_PER_LONG 64
#else
#define BITS_PER_LONG 32
#endif /* CONFIG_64BIT */

/*
 * FIXME: The check currently breaks x86-64 build, so it's
 * temporarily disabled. Please fix x86-64 and reenable
 */
#if 0 && BITS_PER_LONG != __BITS_PER_LONG
#error Inconsistent word size. Check asm/bitsperlong.h
#endif

#ifndef BITS_PER_LONG_LONG
#define BITS_PER_LONG_LONG 64
#endif

/*
 * This file is generally used by user-level software, so you need to
 * be a little careful about namespace pollution etc.
 *
 * First the types that are often defined in different ways across
 * architectures, so that you can override them.
 */

#ifndef __kernel_long_t
typedef long		__kernel_long_t;
typedef unsigned long	__kernel_ulong_t;
#endif

#ifndef __kernel_ino_t
typedef __kernel_ulong_t __kernel_ino_t;
#endif

#ifndef __kernel_mode_t
typedef unsigned int	__kernel_mode_t;
#endif

#ifndef __kernel_pid_t
typedef int		__kernel_pid_t;
#endif

#ifndef __kernel_ipc_pid_t
typedef int		__kernel_ipc_pid_t;
#endif

#ifndef __kernel_uid_t
typedef unsigned int	__kernel_uid_t;
typedef unsigned int	__kernel_gid_t;
#endif

#ifndef __kernel_suseconds_t
typedef __kernel_long_t		__kernel_suseconds_t;
#endif

#ifndef __kernel_daddr_t
typedef int		__kernel_daddr_t;
#endif

#ifndef __kernel_uid32_t
typedef unsigned int	__kernel_uid32_t;
typedef unsigned int	__kernel_gid32_t;
#endif

#ifndef __kernel_old_uid_t
typedef __kernel_uid_t	__kernel_old_uid_t;
typedef __kernel_gid_t	__kernel_old_gid_t;
#endif

#ifndef __kernel_old_dev_t
typedef unsigned int	__kernel_old_dev_t;
#endif

/*
 * Most 32 bit architectures use "unsigned int" size_t,
 * and all 64 bit architectures use "unsigned long" size_t.
 */
#ifndef __kernel_size_t
#if __BITS_PER_LONG != 64
typedef unsigned int	__kernel_size_t;
typedef int		__kernel_ssize_t;
typedef int		__kernel_ptrdiff_t;
#else
typedef __kernel_ulong_t __kernel_size_t;
typedef __kernel_long_t	__kernel_ssize_t;
typedef __kernel_long_t	__kernel_ptrdiff_t;
#endif
#endif

#ifndef __kernel_fsid_t
typedef struct {
	int	val[2];
} __kernel_fsid_t;
#endif

/*
 * anything below here should be completely generic
 */
typedef __kernel_long_t	__kernel_off_t;
typedef long long	__kernel_loff_t;
typedef __kernel_long_t	__kernel_time_t;
typedef __kernel_long_t	__kernel_clock_t;
typedef int		__kernel_timer_t;
typedef int		__kernel_clockid_t;
typedef char *		__kernel_caddr_t;
typedef unsigned short	__kernel_uid16_t;
typedef unsigned short	__kernel_gid16_t;


/*
 * Below are truly Linux-specific types that should never collide with
 * any application/library that wants linux/types.h.
 */

#ifdef __CHECKER__
#define __bitwise__ __attribute__((bitwise))
#else
#define __bitwise__
#endif
#ifdef __CHECK_ENDIAN__
#define __bitwise __bitwise__
#else
#define __bitwise
#endif

typedef __u16 __bitwise __le16;
typedef __u16 __bitwise __be16;
typedef __u32 __bitwise __le32;
typedef __u32 __bitwise __be32;
typedef __u64 __bitwise __le64;
typedef __u64 __bitwise __be64;

typedef __u16 __bitwise __sum16;
typedef __u32 __bitwise __wsum;

/*
 * aligned_u64 should be used in defining kernel<->userspace ABIs to avoid
 * common 32/64-bit compat problems.
 * 64-bit values align to 4-byte boundaries on x86_32 (and possibly other
 * architectures) and to 8-byte boundaries on 64-bit architectures.  The new
 * aligned_64 type enforces 8-byte alignment so that structs containing
 * aligned_64 values have the same alignment on 32-bit and 64-bit architectures.
 * No conversions are necessary between 32-bit user-space and a 64-bit kernel.
 */
#define __aligned_u64 __u64 __attribute__((aligned(8)))
#define __aligned_be64 __be64 __attribute__((aligned(8)))
#define __aligned_le64 __le64 __attribute__((aligned(8)))

#endif /*  __ASSEMBLY__ */

#ifndef __ASSEMBLY__

#define DECLARE_BITMAP(name,bits) \
	unsigned long name[BITS_TO_LONGS(bits)]

typedef __u32 __kernel_dev_t;

typedef __kernel_fd_set		fd_set;
typedef __kernel_dev_t		dev_t;
typedef __kernel_ino_t		ino_t;
typedef __kernel_mode_t		mode_t;
typedef unsigned short		umode_t;
typedef __u32			nlink_t;
typedef __kernel_off_t		off_t;
typedef __kernel_pid_t		pid_t;
typedef __kernel_daddr_t	daddr_t;
typedef __kernel_key_t		key_t;
typedef __kernel_suseconds_t	suseconds_t;
typedef __kernel_timer_t	timer_t;
typedef __kernel_clockid_t	clockid_t;
typedef __kernel_mqd_t		mqd_t;

typedef _Bool			bool;

typedef __kernel_uid32_t	uid_t;
typedef __kernel_gid32_t	gid_t;
typedef __kernel_uid16_t        uid16_t;
typedef __kernel_gid16_t        gid16_t;

typedef unsigned long		uintptr_t;

#ifdef CONFIG_UID16
/* This is defined by include/asm-{arch}/posix_types.h */
typedef __kernel_old_uid_t	old_uid_t;
typedef __kernel_old_gid_t	old_gid_t;
#endif /* CONFIG_UID16 */

#if defined(__GNUC__)
typedef __kernel_loff_t		loff_t;
#endif

/*
 * The following typedefs are also protected by individual ifdefs for
 * historical reasons:
 */
#ifndef _SIZE_T
#define _SIZE_T
typedef __kernel_size_t		size_t;
#endif

#ifndef _SSIZE_T
#define _SSIZE_T
typedef __kernel_ssize_t	ssize_t;
#endif

#ifndef _PTRDIFF_T
#define _PTRDIFF_T
typedef __kernel_ptrdiff_t	ptrdiff_t;
#endif

#ifndef _TIME_T
#define _TIME_T
typedef __kernel_time_t		time_t;
#endif

#ifndef _CLOCK_T
#define _CLOCK_T
typedef __kernel_clock_t	clock_t;
#endif

#ifndef _CADDR_T
#define _CADDR_T
typedef __kernel_caddr_t	caddr_t;
#endif

/* bsd */
typedef unsigned char		u_char;
typedef unsigned short		u_short;
typedef unsigned int		u_int;
typedef unsigned long		u_long;

/* sysv */
typedef unsigned char		unchar;
typedef unsigned short		ushort;
typedef unsigned int		uint;
typedef unsigned long		ulong;

#ifndef __BIT_TYPES_DEFINED__
#define __BIT_TYPES_DEFINED__

typedef		__u8		u_int8_t;
typedef		__s8		int8_t;
typedef		__u16		u_int16_t;
typedef		__s16		int16_t;
typedef		__u32		u_int32_t;
typedef		__s32		int32_t;

#endif /* !(__BIT_TYPES_DEFINED__) */

typedef		__u8		uint8_t;
typedef		__u16		uint16_t;
typedef		__u32		uint32_t;

#if defined(__GNUC__)
typedef		__u64		uint64_t;
typedef		__u64		u_int64_t;
typedef		__s64		int64_t;
#endif

/* this is a special 64bit data type that is 8-byte aligned */
#define aligned_u64 __u64 __attribute__((aligned(8)))
#define aligned_be64 __be64 __attribute__((aligned(8)))
#define aligned_le64 __le64 __attribute__((aligned(8)))

/**
 * The type used for indexing onto a disc or disc partition.
 *
 * Linux always considers sectors to be 512 bytes long independently
 * of the devices real block size.
 *
 * blkcnt_t is the type of the inode's block count.
 */
#ifdef CONFIG_LBDAF
typedef u64 sector_t;
typedef u64 blkcnt_t;
#else
typedef unsigned long sector_t;
typedef unsigned long blkcnt_t;
#endif

/*
 * The type of an index into the pagecache.  Use a #define so asm/types.h
 * can override it.
 */
#ifndef pgoff_t
#define pgoff_t unsigned long
#endif

/* A dma_addr_t can hold any valid DMA or bus address for the platform */
#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
typedef u64 dma_addr_t;
#else
typedef u32 dma_addr_t;
#endif /* dma_addr_t */

#ifdef __CHECKER__
#else
#endif
#ifdef __CHECK_ENDIAN__
#else
#endif
typedef unsigned __bitwise__ gfp_t;
typedef unsigned __bitwise__ fmode_t;
typedef unsigned __bitwise__ oom_flags_t;

#ifdef CONFIG_PHYS_ADDR_T_64BIT
typedef u64 phys_addr_t;
#else
typedef u32 phys_addr_t;
#endif

typedef phys_addr_t resource_size_t;

/*
 * This type is the placeholder for a hardware interrupt number. It has to be
 * big enough to enclose whatever representation is used by a given platform.
 */
typedef unsigned long irq_hw_number_t;

typedef struct {
	int counter;
} atomic_t;

#ifdef CONFIG_64BIT
typedef struct {
	long counter;
} atomic64_t;
#endif

struct list_head {
	struct list_head *next, *prev;
};

struct hlist_head {
	struct hlist_node *first;
};

struct hlist_node {
	struct hlist_node *next, **pprev;
};

struct ustat {
	__kernel_daddr_t	f_tfree;
	__kernel_ino_t		f_tinode;
	char			f_fname[6];
	char			f_fpack[6];
};

/**
 * struct callback_head - callback structure for use with RCU and task_work
 * @next: next update requests in a list
 * @func: actual update function to call after the grace period.
 */
struct callback_head {
	struct callback_head *next;
	void (*func)(struct callback_head *head);
};
#define rcu_head callback_head

#endif /*  __ASSEMBLY__ */




/*
* Include machine specific inline routines
*/
//#include <asm/string.h>




#define __HAVE_ARCH_STRCMP


#define __HAVE_ARCH_STRNCMP


#define __HAVE_ARCH_STRLEN


#define __HAVE_ARCH_STRNLEN


#define __HAVE_ARCH_MEMCPY

#define __HAVE_ARCH_MEMMOVE




#define __HAVE_ARCH_MEMSET


#define __HAVE_ARCH_MEMCMP


#ifndef __HAVE_ARCH_STRLCPY

#endif

#ifndef __HAVE_ARCH_STRCPY

#endif

#ifndef __HAVE_ARCH_STRCASECMP

#endif














#ifdef CONFIG_BINARY_PRINTF
int vbin_printf(u32 *bin_buf, size_t size, const char *fmt, va_list args);
int bstr_printf(char *buf, size_t size, const char *fmt, const u32 *bin_buf);
int bprintf(u32 *bin_buf, size_t size, const char *fmt, ...) __printf(3, 4);
#endif






/**
* kbasename - return the last part of a pathname.
*
* @path: path to extract the filename from.
*/
static inline const char *kbasename(const char *path)
{

	return path;
}


#ifdef __ASSEMBLY__
#define _AC(X,Y)        X
#define _AT(T,X)        X
#else
#define __AC(X,Y)       (X##Y)
#define _AC(X,Y)        __AC(X,Y)
#define _AT(T,X)        ((T)(X))
#endif

# define POISON_POINTER_DELTA 0
#define POISON_INUSE    0x5a    /* for use-uninitialised poisoning */
#define LIST_POISON1  ((void *) 0x00100100 + POISON_POINTER_DELTA)
#define LIST_POISON2  ((void *) 0x00200200 + POISON_POINTER_DELTA)

/*
* Simple doubly linked list implementation.
*
* Some of the internal functions ("__xxx") are useful when
* manipulating whole lists rather than single entries, as
* sometimes we already know the next/prev entries and we can
* generate better code by using them directly rather than
* using the generic single-entry routines.
*/

#define LIST_HEAD_INIT(name) { &(name), &(name) }

#define LIST_HEAD(name) \
	struct list_head name = LIST_HEAD_INIT(name)

static inline void INIT_LIST_HEAD(struct list_head *list)
{
	list->next = list;
	list->prev = list;
}

/*
* Insert a new entry between two known consecutive entries.
*
* This is only for internal list manipulation where we know
* the prev/next entries already!
*/

static inline void __list_add(struct list_head *new,
						struct list_head *prev,
						struct list_head *next)
{
	next->prev = new;
	new->next = next;
	new->prev = prev;
	prev->next = new;
}


/**
* list_add - add a new entry
* @new: new entry to be added
* @head: list head to add it after
*
* Insert a new entry after the specified head.
* This is good for implementing stacks.
*/
static inline void list_add(struct list_head *new, struct list_head *head)
{
	__list_add(new, head, head->next);
}


/**
* list_add_tail - add a new entry
* @new: new entry to be added
* @head: list head to add it before
*
* Insert a new entry before the specified head.
* This is useful for implementing queues.
*/
static inline void list_add_tail(struct list_head *new, struct list_head *head)
{
	__list_add(new, head->prev, head);
}

/*
* Delete a list entry by making the prev/next entries
* point to each other.
*
* This is only for internal list manipulation where we know
* the prev/next entries already!
*/
static inline void __list_del(struct list_head * prev, struct list_head * next)
{
	next->prev = prev;
	prev->next = next;
}

/**
* list_del - deletes entry from list.
* @entry: the element to delete from the list.
* Note: list_empty() on entry does not return true after this, the entry is
* in an undefined state.
*/

static inline void __list_del_entry(struct list_head *entry)
{
	__list_del(entry->prev, entry->next);
}

static inline void list_del(struct list_head *entry)
{
	__list_del(entry->prev, entry->next);
	entry->next = LIST_POISON1;
	entry->prev = LIST_POISON2;
}

/**
* list_replace - replace old entry by new one
* @old : the element to be replaced
* @new : the new element to insert
*
* If @old was empty, it will be overwritten.
*/
static inline void list_replace(struct list_head *old,
				struct list_head *new)
{
	new->next = old->next;
	new->next->prev = new;
	new->prev = old->prev;
	new->prev->next = new;
}

static inline void list_replace_init(struct list_head *old,
					struct list_head *new)
{
	list_replace(old, new);
	INIT_LIST_HEAD(old);
}

/**
* list_del_init - deletes entry from list and reinitialize it.
* @entry: the element to delete from the list.
*/
static inline void list_del_init(struct list_head *entry)
{
	__list_del_entry(entry);
	INIT_LIST_HEAD(entry);
}

/**
* list_move - delete from one list and add as another's head
* @list: the entry to move
* @head: the head that will precede our entry
*/
static inline void list_move(struct list_head *list, struct list_head *head)
{
	__list_del_entry(list);
	list_add(list, head);
}

/**
* list_move_tail - delete from one list and add as another's tail
* @list: the entry to move
* @head: the head that will follow our entry
*/
static inline void list_move_tail(struct list_head *list,
					struct list_head *head)
{
	__list_del_entry(list);
	list_add_tail(list, head);
}

/**
* list_is_last - tests whether @list is the last entry in list @head
* @list: the entry to test
* @head: the head of the list
*/
static inline int list_is_last(const struct list_head *list,
				const struct list_head *head)
{
	return list->next == head;
}

/**
* list_empty - tests whether a list is empty
* @head: the list to test.
*/
static inline int list_empty(const struct list_head *head)
{
	return head->next == head;
}

/**
* list_empty_careful - tests whether a list is empty and not being modified
* @head: the list to test
*
* Description:
* tests whether a list is empty _and_ checks that no other CPU might be
* in the process of modifying either member (next or prev)
*
* NOTE: using list_empty_careful() without synchronization
* can only be safe if the only activity that can happen
* to the list entry is list_del_init(). Eg. it cannot be used
* if another CPU could re-list_add() it.
*/
static inline int list_empty_careful(const struct list_head *head)
{
	struct list_head *next = head->next;
	return (next == head) && (next == head->prev);
}

/**
* list_rotate_left - rotate the list to the left
* @head: the head of the list
*/
static inline void list_rotate_left(struct list_head *head)
{
	struct list_head *first;

	if (!list_empty(head)) {
		first = head->next;
		list_move_tail(first, head);
	}
}

/**
* list_is_singular - tests whether a list has just one entry.
* @head: the list to test.
*/
static inline int list_is_singular(const struct list_head *head)
{
	return !list_empty(head) && (head->next == head->prev);
}

static inline void __list_cut_position(struct list_head *list,
		struct list_head *head, struct list_head *entry)
{
	struct list_head *new_first = entry->next;
	list->next = head->next;
	list->next->prev = list;
	list->prev = entry;
	entry->next = list;
	head->next = new_first;
	new_first->prev = head;
}

/**
* list_cut_position - cut a list into two
* @list: a new list to add all removed entries
* @head: a list with entries
* @entry: an entry within head, could be the head itself
*	and if so we won't cut the list
*
* This helper moves the initial part of @head, up to and
* including @entry, from @head to @list. You should
* pass on @entry an element you know is on @head. @list
* should be an empty list or a list you do not care about
* losing its data.
*
*/
static inline void list_cut_position(struct list_head *list,
		struct list_head *head, struct list_head *entry)
{
	if (list_empty(head))
		return;
	if (list_is_singular(head) &&
		(head->next != entry && head != entry))
		return;
	if (entry == head)
		INIT_LIST_HEAD(list);
	else
		__list_cut_position(list, head, entry);
}

static inline void __list_splice(const struct list_head *list,
				struct list_head *prev,
				struct list_head *next)
{
	struct list_head *first = list->next;
	struct list_head *last = list->prev;

	first->prev = prev;
	prev->next = first;

	last->next = next;
	next->prev = last;
}

/**
* list_splice - join two lists, this is designed for stacks
* @list: the new list to add.
* @head: the place to add it in the first list.
*/
static inline void list_splice(const struct list_head *list,
				struct list_head *head)
{
	if (!list_empty(list))
		__list_splice(list, head, head->next);
}

/**
* list_splice_tail - join two lists, each list being a queue
* @list: the new list to add.
* @head: the place to add it in the first list.
*/
static inline void list_splice_tail(struct list_head *list,
				struct list_head *head)
{
	if (!list_empty(list))
		__list_splice(list, head->prev, head);
}

/**
* list_splice_init - join two lists and reinitialise the emptied list.
* @list: the new list to add.
* @head: the place to add it in the first list.
*
* The list at @list is reinitialised
*/
static inline void list_splice_init(struct list_head *list,
						struct list_head *head)
{
	if (!list_empty(list)) {
		__list_splice(list, head, head->next);
		INIT_LIST_HEAD(list);
	}
}

/**
* list_splice_tail_init - join two lists and reinitialise the emptied list
* @list: the new list to add.
* @head: the place to add it in the first list.
*
* Each of the lists is a queue.
* The list at @list is reinitialised
*/
static inline void list_splice_tail_init(struct list_head *list,
					struct list_head *head)
{
	if (!list_empty(list)) {
		__list_splice(list, head->prev, head);
		INIT_LIST_HEAD(list);
	}
}

/**
* list_entry - get the struct for this entry
* @ptr:	the &struct list_head pointer.
* @type:	the type of the struct this is embedded in.
* @member:	the name of the list_struct within the struct.
*/
#define list_entry(ptr, type, member) \
	container_of(ptr, type, member)

/**
* list_first_entry - get the first element from a list
* @ptr:	the list head to take the element from.
* @type:	the type of the struct this is embedded in.
* @member:	the name of the list_struct within the struct.
*
* Note, that list is expected to be not empty.
*/
#define list_first_entry(ptr, type, member) \
	list_entry((ptr)->next, type, member)

/**
* list_last_entry - get the last element from a list
* @ptr:	the list head to take the element from.
* @type:	the type of the struct this is embedded in.
* @member:	the name of the list_struct within the struct.
*
* Note, that list is expected to be not empty.
*/
#define list_last_entry(ptr, type, member) \
	list_entry((ptr)->prev, type, member)

/**
* list_first_entry_or_null - get the first element from a list
* @ptr:	the list head to take the element from.
* @type:	the type of the struct this is embedded in.
* @member:	the name of the list_struct within the struct.
*
* Note that if the list is empty, it returns NULL.
*/
#define list_first_entry_or_null(ptr, type, member) \
	(!list_empty(ptr) ? list_first_entry(ptr, type, member) : NULL)

/**
* list_next_entry - get the next element in list
* @pos:	the type * to cursor
* @member:	the name of the list_struct within the struct.
*/
#define list_next_entry(pos, member) \
	list_entry((pos)->member.next, typeof(*(pos)), member)

/**
* list_prev_entry - get the prev element in list
* @pos:	the type * to cursor
* @member:	the name of the list_struct within the struct.
*/
#define list_prev_entry(pos, member) \
	list_entry((pos)->member.prev, typeof(*(pos)), member)

/**
* list_for_each	-	iterate over a list
* @pos:	the &struct list_head to use as a loop cursor.
* @head:	the head for your list.
*/
#define list_for_each(pos, head) \
	for (pos = (head)->next; pos != (head); pos = pos->next)

/**
* list_for_each_prev	-	iterate over a list backwards
* @pos:	the &struct list_head to use as a loop cursor.
* @head:	the head for your list.
*/
#define list_for_each_prev(pos, head) \
	for (pos = (head)->prev; pos != (head); pos = pos->prev)

/**
* list_for_each_safe - iterate over a list safe against removal of list entry
* @pos:	the &struct list_head to use as a loop cursor.
* @n:		another &struct list_head to use as temporary storage
* @head:	the head for your list.
*/
#define list_for_each_safe(pos, n, head) \
	for (pos = (head)->next, n = pos->next; pos != (head); \
		pos = n, n = pos->next)

/**
* list_for_each_prev_safe - iterate over a list backwards safe against removal of list entry
* @pos:	the &struct list_head to use as a loop cursor.
* @n:		another &struct list_head to use as temporary storage
* @head:	the head for your list.
*/
#define list_for_each_prev_safe(pos, n, head) \
	for (pos = (head)->prev, n = pos->prev; \
			pos != (head); \
			pos = n, n = pos->prev)

/**
* list_for_each_entry	-	iterate over list of given type
* @pos:	the type * to use as a loop cursor.
* @head:	the head for your list.
* @member:	the name of the list_struct within the struct.
*/
#define list_for_each_entry(pos, head, member)				\
	for (pos = list_first_entry(head, typeof(*pos), member);	\
			&pos->member != (head);					\
			pos = list_next_entry(pos, member))

/**
* list_for_each_entry_reverse - iterate backwards over list of given type.
* @pos:	the type * to use as a loop cursor.
* @head:	the head for your list.
* @member:	the name of the list_struct within the struct.
*/
#define list_for_each_entry_reverse(pos, head, member)			\
	for (pos = list_last_entry(head, typeof(*pos), member);		\
			&pos->member != (head); 					\
			pos = list_prev_entry(pos, member))

/**
* list_prepare_entry - prepare a pos entry for use in list_for_each_entry_continue()
* @pos:	the type * to use as a start point
* @head:	the head of the list
* @member:	the name of the list_struct within the struct.
*
* Prepares a pos entry for use as a start point in list_for_each_entry_continue().
*/
#define list_prepare_entry(pos, head, member) \
	((pos) ? : list_entry(head, typeof(*pos), member))

/**
* list_for_each_entry_continue - continue iteration over list of given type
* @pos:	the type * to use as a loop cursor.
* @head:	the head for your list.
* @member:	the name of the list_struct within the struct.
*
* Continue to iterate over list of given type, continuing after
* the current position.
*/
#define list_for_each_entry_continue(pos, head, member) 		\
	for (pos = list_next_entry(pos, member);			\
			&pos->member != (head);					\
			pos = list_next_entry(pos, member))

/**
* list_for_each_entry_continue_reverse - iterate backwards from the given point
* @pos:	the type * to use as a loop cursor.
* @head:	the head for your list.
* @member:	the name of the list_struct within the struct.
*
* Start to iterate over list of given type backwards, continuing after
* the current position.
*/
#define list_for_each_entry_continue_reverse(pos, head, member)		\
	for (pos = list_prev_entry(pos, member);			\
			&pos->member != (head);					\
			pos = list_prev_entry(pos, member))

/**
* list_for_each_entry_from - iterate over list of given type from the current point
* @pos:	the type * to use as a loop cursor.
* @head:	the head for your list.
* @member:	the name of the list_struct within the struct.
*
* Iterate over list of given type, continuing from current position.
*/
#define list_for_each_entry_from(pos, head, member) 			\
	for (; &pos->member != (head);					\
			pos = list_next_entry(pos, member))

/**
* list_for_each_entry_safe - iterate over list of given type safe against removal of list entry
* @pos:	the type * to use as a loop cursor.
* @n:		another type * to use as temporary storage
* @head:	the head for your list.
* @member:	the name of the list_struct within the struct.
*/
#define list_for_each_entry_safe(pos, n, head, member)			\
	for (pos = list_first_entry(head, typeof(*pos), member),	\
		n = list_next_entry(pos, member);			\
			&pos->member != (head); 					\
			pos = n, n = list_next_entry(n, member))

/**
* list_for_each_entry_safe_continue - continue list iteration safe against removal
* @pos:	the type * to use as a loop cursor.
* @n:		another type * to use as temporary storage
* @head:	the head for your list.
* @member:	the name of the list_struct within the struct.
*
* Iterate over list of given type, continuing after current point,
* safe against removal of list entry.
*/
#define list_for_each_entry_safe_continue(pos, n, head, member) 		\
	for (pos = list_next_entry(pos, member), 				\
		n = list_next_entry(pos, member);				\
			&pos->member != (head);						\
			pos = n, n = list_next_entry(n, member))

/**
* list_for_each_entry_safe_from - iterate over list from current point safe against removal
* @pos:	the type * to use as a loop cursor.
* @n:		another type * to use as temporary storage
* @head:	the head for your list.
* @member:	the name of the list_struct within the struct.
*
* Iterate over list of given type from current point, safe against
* removal of list entry.
*/
#define list_for_each_entry_safe_from(pos, n, head, member) 			\
	for (n = list_next_entry(pos, member);					\
			&pos->member != (head);						\
			pos = n, n = list_next_entry(n, member))

/**
* list_for_each_entry_safe_reverse - iterate backwards over list safe against removal
* @pos:	the type * to use as a loop cursor.
* @n:		another type * to use as temporary storage
* @head:	the head for your list.
* @member:	the name of the list_struct within the struct.
*
* Iterate backwards over list of given type, safe against removal
* of list entry.
*/
#define list_for_each_entry_safe_reverse(pos, n, head, member)		\
	for (pos = list_last_entry(head, typeof(*pos), member),		\
		n = list_prev_entry(pos, member);			\
			&pos->member != (head); 					\
			pos = n, n = list_prev_entry(n, member))

/**
* list_safe_reset_next - reset a stale list_for_each_entry_safe loop
* @pos:	the loop cursor used in the list_for_each_entry_safe loop
* @n:		temporary storage used in list_for_each_entry_safe
* @member:	the name of the list_struct within the struct.
*
* list_safe_reset_next is not safe to use in general if the list may be
* modified concurrently (eg. the lock is dropped in the loop body). An
* exception to this is if the cursor element (pos) is pinned in the list,
* and list_safe_reset_next is called after re-taking the lock and before
* completing the current iteration of the loop body.
*/
#define list_safe_reset_next(pos, n, member)				\
	n = list_next_entry(pos, member)

/*
* Double linked lists with a single pointer list head.
* Mostly useful for hash tables where the two pointer list head is
* too wasteful.
* You lose the ability to access the tail in O(1).
*/

#define HLIST_HEAD_INIT { .first = NULL }
#define HLIST_HEAD(name) struct hlist_head name = {  .first = NULL }
#define INIT_HLIST_HEAD(ptr) ((ptr)->first = NULL)
static inline void INIT_HLIST_NODE(struct hlist_node *h)
{
	h->next = NULL;
	h->pprev = NULL;
}

static inline int hlist_unhashed(const struct hlist_node *h)
{
	return !h->pprev;
}

static inline int hlist_empty(const struct hlist_head *h)
{
	return !h->first;
}

static inline void __hlist_del(struct hlist_node *n)
{
	struct hlist_node *next = n->next;
	struct hlist_node **pprev = n->pprev;
	*pprev = next;
	if (next)
		next->pprev = pprev;
}

static inline void hlist_del(struct hlist_node *n)
{
	__hlist_del(n);
	n->next = LIST_POISON1;
	n->pprev = LIST_POISON2;
}

static inline void hlist_del_init(struct hlist_node *n)
{
	if (!hlist_unhashed(n)) {
		__hlist_del(n);
		INIT_HLIST_NODE(n);
	}
}

static inline void hlist_add_head(struct hlist_node *n, struct hlist_head *h)
{
	struct hlist_node *first = h->first;
	n->next = first;
	if (first)
		first->pprev = &n->next;
	h->first = n;
	n->pprev = &h->first;
}

/* next must be != NULL */
static inline void hlist_add_before(struct hlist_node *n,
					struct hlist_node *next)
{
	n->pprev = next->pprev;
	n->next = next;
	next->pprev = &n->next;
	*(n->pprev) = n;
}

static inline void hlist_add_after(struct hlist_node *n,
					struct hlist_node *next)
{
	next->next = n->next;
	n->next = next;
	next->pprev = &n->next;

	if(next->next)
		next->next->pprev  = &next->next;
}

/* after that we'll appear to be on some hlist and hlist_del will work */
static inline void hlist_add_fake(struct hlist_node *n)
{
	n->pprev = &n->next;
}

/*
* Move a list from one list head to another. Fixup the pprev
* reference of the first entry if it exists.
*/
static inline void hlist_move_list(struct hlist_head *old,
					struct hlist_head *new)
{
	new->first = old->first;
	if (new->first)
		new->first->pprev = &new->first;
	old->first = NULL;
}

#define hlist_entry(ptr, type, member) container_of(ptr,type,member)

#define hlist_for_each(pos, head) \
	for (pos = (head)->first; pos ; pos = pos->next)

#define hlist_for_each_safe(pos, n, head) \
	for (pos = (head)->first; pos && ({ n = pos->next; 1; }); \
			pos = n)

#define hlist_entry_safe(ptr, type, member) \
	({ typeof(ptr) ____ptr = (ptr); \
		____ptr ? hlist_entry(____ptr, type, member) : NULL; \
	})

/**
* hlist_for_each_entry	- iterate over list of given type
* @pos:	the type * to use as a loop cursor.
* @head:	the head for your list.
* @member:	the name of the hlist_node within the struct.
*/
#define hlist_for_each_entry(pos, head, member)				\
	for (pos = hlist_entry_safe((head)->first, typeof(*(pos)), member);\
			pos;							\
			pos = hlist_entry_safe((pos)->member.next, typeof(*(pos)), member))

/**
* hlist_for_each_entry_continue - iterate over a hlist continuing after current point
* @pos:	the type * to use as a loop cursor.
* @member:	the name of the hlist_node within the struct.
*/
#define hlist_for_each_entry_continue(pos, member)			\
	for (pos = hlist_entry_safe((pos)->member.next, typeof(*(pos)), member);\
			pos;							\
			pos = hlist_entry_safe((pos)->member.next, typeof(*(pos)), member))

/**
* hlist_for_each_entry_from - iterate over a hlist continuing from current point
* @pos:	the type * to use as a loop cursor.
* @member:	the name of the hlist_node within the struct.
*/
#define hlist_for_each_entry_from(pos, member)				\
	for (; pos;							\
			pos = hlist_entry_safe((pos)->member.next, typeof(*(pos)), member))

/**
* hlist_for_each_entry_safe - iterate over list of given type safe against removal of list entry
* @pos:	the type * to use as a loop cursor.
* @n:		another &struct hlist_node to use as temporary storage
* @head:	the head for your list.
* @member:	the name of the hlist_node within the struct.
*/
#define hlist_for_each_entry_safe(pos, n, head, member) 		\
	for (pos = hlist_entry_safe((head)->first, typeof(*pos), member);\
			pos && ({ n = pos->member.next; 1; });			\
			pos = hlist_entry_safe(n, typeof(*pos), member))


#endif /* _LINUX_TYPES_H */
