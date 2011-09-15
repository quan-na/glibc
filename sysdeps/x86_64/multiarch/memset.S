/* Multiple versions of memset
   Copyright (C) 2014 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#include <sysdep.h>
#include <init-arch.h>

/* Define multiple versions only for the definition in lib.  */
#ifndef NOT_IN_libc
ENTRY(memset)
	.type	memset, @gnu_indirect_function
	cmpl	$0, __cpu_features+KIND_OFFSET(%rip)
	jne	1f
	call	__init_cpu_features
1:	leaq	__memset_erms(%rip), %rax
	testl	$bit_ERMS, __cpu_features+CPUID_OFFSET+index_ERMS(%rip)
	jnz	2f
	leaq	__memset_sse2(%rip), %rax
2:	ret
END(memset)

# define __bzero __bzero_sse2
# define memset __memset_sse2
# define __memset_chk __memset_chk_sse2

# ifdef SHARED
#  undef libc_hidden_builtin_def
/* It doesn't make sense to send libc-internal memset calls through a PLT.
   The speedup we get from using GPR instruction is likely eaten away
   by the indirect call in the PLT.  */
#  define libc_hidden_builtin_def(name) \
	.globl __GI_memset; __GI_memset = __memset_sse2
# endif

# undef weak_alias
# define weak_alias(original, alias)
#endif

#include "../memset.S"
