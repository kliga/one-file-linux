/*
 * Low-level exception handling code
 *
 * Copyright (C) 2012 ARM Ltd.
 * Authors:	Catalin Marinas <catalin.marinas@arm.com>
 *		Will Deacon <will.deacon@arm.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#ifdef CONFIG_HAVE_UNDERSCORE_SYMBOL_PREFIX
#define __VMLINUX_SYMBOL(x) _##x
#define __VMLINUX_SYMBOL_STR(x) "_" #x
#else
#define __VMLINUX_SYMBOL(x) x
#define __VMLINUX_SYMBOL_STR(x) #x
#endif


#define VMLINUX_SYMBOL(x) __VMLINUX_SYMBOL(x)
#define VMLINUX_SYMBOL_STR(x) __VMLINUX_SYMBOL_STR(x)

#ifndef ASM_NL
#define ASM_NL		 ;
#endif

#define __page_aligned_data	__section(.data..page_aligned) __aligned(PAGE_SIZE)
#define __page_aligned_bss	__section(.bss..page_aligned) __aligned(PAGE_SIZE)

#define __PAGE_ALIGNED_DATA	.section ".data..page_aligned", "aw"
#define __PAGE_ALIGNED_BSS	.section ".bss..page_aligned", "aw"

#define __ALIGN		.align 4,0x90
#define __ALIGN_STR	".align 4,0x90"


#define ALIGN __ALIGN
#define ALIGN_STR __ALIGN_STR


#define ENTRY(name) \
  .globl name ASM_NL \
  ALIGN ASM_NL \
  name:

#define END(name) \
  .size name, .-name

#define ENDPROC(name) \
  .type name, @function ASM_NL \
  END(name)

#define THREAD_SIZE		16384
#define THREAD_START_SP		(THREAD_SIZE - 16)

#define PSR_MODE_MASK   0x0000000f

#define TIF_SIGPENDING		0
#define TIF_NEED_RESCHED	1
#define TIF_NOTIFY_RESUME	2	/* callback before returning to user */
#define TIF_FOREIGN_FPSTATE	3	/* CPU's FP state is not current's */
#define TIF_SYSCALL_TRACE	8
#define TIF_SYSCALL_AUDIT	9
#define TIF_SYSCALL_TRACEPOINT	10
#define TIF_SECCOMP		11
#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
#define TIF_FREEZE		19
#define TIF_RESTORE_SIGMASK	20
#define TIF_SINGLESTEP		21
#define TIF_32BIT		22	/* 32bit process */
#define TIF_SWITCH_MM		23	/* deferred switch_mm */

#define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
#define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
#define _TIF_FOREIGN_FPSTATE	(1 << TIF_FOREIGN_FPSTATE)
#define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
#define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
#define _TIF_SYSCALL_TRACEPOINT	(1 << TIF_SYSCALL_TRACEPOINT)
#define _TIF_SECCOMP		(1 << TIF_SECCOMP)
#define _TIF_32BIT		(1 << TIF_32BIT)


#define _TIF_WORK_MASK		(_TIF_NEED_RESCHED | _TIF_SIGPENDING | \
        _TIF_NOTIFY_RESUME | _TIF_FOREIGN_FPSTATE)


/*
 * Register aliases.
 */
lr	.req	x30		// link register




	.macro	enable_step_tsk, flgs, tmp
	tbz	\flgs, #TIF_SINGLESTEP, 9990f
	disable_dbg
	mrs	\tmp, mdscr_el1
	orr	\tmp, \tmp, #1
	msr	mdscr_el1, \tmp
9990:
	.endm

	 .macro	ventry	label
	.align	7
	b	\label
	.endm

  	.macro	push, xreg1, xreg2
	stp	\xreg1, \xreg2, [sp, #-16]!
	.endm

	.macro	pop, xreg1, xreg2
	ldp	\xreg1, \xreg2, [sp], #16
	.endm

	.macro	enable_dbg
	msr	daifclr, #8
	.endm

	.macro	enable_dbg_and_irq
	msr	daifclr, #(8 | 2)
	.endm

	.macro	disable_irq
	msr	daifset, #2
	.endm

	.macro	enable_irq
	msr	daifclr, #2
	.endm

	.macro	disable_dbg
	msr	daifset, #8
	.endm

	.macro	disable_step_tsk, flgs, tmp
	tbz	\flgs, #TIF_SINGLESTEP, 9990f
	mrs	\tmp, mdscr_el1
	bic	\tmp, \tmp, #1
	msr	mdscr_el1, \tmp
	isb	// Synchronise with enable_dbg
9990:
	.endm

#define S_PSTATE 264
#define S_X2 16
#define S_X1 8
#define S_X0 0
#define S_SP 248
#define THREAD_CPU_CONTEXT 1152
#define S_SYSCALLNO 280
#define TI_FLAGS 0
#define S_PC 256
#define S_LR 240
#define S_FRAME_SIZE 288
#define S_ORIG_X0 272



#define ESR_EL1_EC_SHIFT	(26)
#define ESR_EL1_EC_DABT_EL1	(0x25)
#define ESR_EL1_EC_SYS64	(0x18)
#define ESR_EL1_EC_SP_ALIGN	(0x26)
#define ESR_EL1_EC_PC_ALIGN	(0x22)
#define ESR_EL1_EC_UNKNOWN	(0x00)
#define ESR_EL1_EC_BREAKPT_EL1	(0x31)
#define ESR_EL1_EC_BRK64	(0x3C)
#define ESR_EL1_EC_SVC64	(0x15)
#define ESR_EL1_EC_DABT_EL0	(0x24)
#define ESR_EL1_EC_IABT_EL0	(0x20)
#define ESR_EL1_EC_FP_ASIMD	(0x07)
#define ESR_EL1_EC_FP_EXC64	(0x2C)
#define ESR_EL1_EC_BREAKPT_EL0	(0x30)
#define ESR_EL1_EC_SVC32	(0x11)
#define ESR_EL1_EC_FP_EXC32	(0x28)
#define ESR_EL1_EC_CP15_32	(0x03)
#define ESR_EL1_EC_CP15_64	(0x04)
#define ESR_EL1_EC_CP14_MR	(0x05)
#define ESR_EL1_EC_CP14_LS	(0x06)
#define ESR_EL1_EC_CP14_64	(0x0C)
#define ESR_EL1_EC_BREAKPT_EL0	(0x30)



#define __NR_syscalls 277
#define __NR_compat_syscalls		383

#ifdef __ASSEMBLY__
#define _AC(X,Y)        X
#define _AT(T,X)        X
#else
#define __AC(X,Y)       (X##Y)
#define _AC(X,Y)        __AC(X,Y)
#define _AT(T,X)        ((T)(X))
#endif


#define PAGE_SHIFT              12
#define PAGE_SIZE               (_AC(1,UL) << PAGE_SHIFT)


#define BAD_SYNC	0
#define BAD_IRQ		1
#define BAD_FIQ		2
#define BAD_ERROR	3

	.macro	kernel_entry, el, regsize = 64
	sub	sp, sp, #S_FRAME_SIZE - S_LR	// room for LR, SP, SPSR, ELR
	.if	\regsize == 32
	mov	w0, w0				// zero upper 32 bits of x0
	.endif
	push	x28, x29
	push	x26, x27
	push	x24, x25
	push	x22, x23
	push	x20, x21
	push	x18, x19
	push	x16, x17
	push	x14, x15
	push	x12, x13
	push	x10, x11
	push	x8, x9
	push	x6, x7
	push	x4, x5
	push	x2, x3
	push	x0, x1
	.if	\el == 0
	mrs	x21, sp_el0
	get_thread_info tsk			// Ensure MDSCR_EL1.SS is clear,
	ldr	x19, [tsk, #TI_FLAGS]		// since we can unmask debug
	disable_step_tsk x19, x20		// exceptions when scheduling.
	.else
	add	x21, sp, #S_FRAME_SIZE
	.endif
	mrs	x22, elr_el1
	mrs	x23, spsr_el1
	stp	lr, x21, [sp, #S_LR]
	stp	x22, x23, [sp, #S_PC]

	/*
	 * Set syscallno to -1 by default (overridden later if real syscall).
	 */
	.if	\el == 0
	mvn	x21, xzr
	str	x21, [sp, #S_SYSCALLNO]
	.endif

	/*
	 * Registers that may be useful after this macro is invoked:
	 *
	 * x21 - aborted SP
	 * x22 - aborted PC
	 * x23 - aborted PSTATE
	*/
	.endm

	.macro	kernel_exit, el, ret = 0
	ldp	x21, x22, [sp, #S_PC]		// load ELR, SPSR
	.if	\el == 0
	ldr	x23, [sp, #S_SP]		// load return stack pointer
	.endif
	.if	\ret
	ldr	x1, [sp, #S_X1]			// preserve x0 (syscall return)
	add	sp, sp, S_X2
	.else
	pop	x0, x1
	.endif
	pop	x2, x3				// load the rest of the registers
	pop	x4, x5
	pop	x6, x7
	pop	x8, x9
	msr	elr_el1, x21			// set up the return data
	msr	spsr_el1, x22
	.if	\el == 0
	msr	sp_el0, x23
	.endif
	pop	x10, x11
	pop	x12, x13
	pop	x14, x15
	pop	x16, x17
	pop	x18, x19
	pop	x20, x21
	pop	x22, x23
	pop	x24, x25
	pop	x26, x27
	pop	x28, x29
	ldr	lr, [sp], #S_FRAME_SIZE - S_LR	// load LR and restore SP
	eret					// return to kernel
	.endm

	.macro	get_thread_info, rd
	mov	\rd, sp
	and	\rd, \rd, #~(THREAD_SIZE - 1)	// top of stack
	.endm

/*
 * These are the registers used in the syscall handler, and allow us to
 * have in theory up to 7 arguments to a function - x0 to x6.
 *
 * x7 is reserved for the system call number in 32-bit mode.
 */
sc_nr	.req	x25		// number of system calls
scno	.req	x26		// syscall number
stbl	.req	x27		// syscall table pointer
tsk	.req	x28		// current thread_info

/*
 * Interrupt handling.
 */
	.macro	irq_handler
	ldr	x1, handle_arch_irq_tlx
	mov	x0, sp
	blr	x1
	.endm

	.text

/*
 * Exception vectors.
 */

	.align	11
ENTRY(vectors)
	ventry	el1_sync_invalid		// Synchronous EL1t
	ventry	el1_irq_invalid			// IRQ EL1t
	ventry	el1_fiq_invalid			// FIQ EL1t
	ventry	el1_error_invalid		// Error EL1t

	ventry	el1_sync			// Synchronous EL1h
	ventry	el1_irq				// IRQ EL1h
	ventry	el1_fiq_invalid			// FIQ EL1h
	ventry	el1_error_invalid		// Error EL1h

	ventry	el0_sync			// Synchronous 64-bit EL0
	ventry	el0_irq				// IRQ 64-bit EL0
	ventry	el0_fiq_invalid			// FIQ 64-bit EL0
	ventry	el0_error_invalid		// Error 64-bit EL0

#ifdef CONFIG_COMPAT
	ventry	el0_sync_compat			// Synchronous 32-bit EL0
	ventry	el0_irq_compat			// IRQ 32-bit EL0
	ventry	el0_fiq_invalid_compat		// FIQ 32-bit EL0
	ventry	el0_error_invalid_compat	// Error 32-bit EL0
#else
	ventry	el0_sync_invalid		// Synchronous 32-bit EL0
	ventry	el0_irq_invalid			// IRQ 32-bit EL0
	ventry	el0_fiq_invalid			// FIQ 32-bit EL0
	ventry	el0_error_invalid		// Error 32-bit EL0
#endif
END(vectors)

/*
 * Invalid mode handlers
 */
	.macro	inv_entry, el, reason, regsize = 64
	kernel_entry el, \regsize
	mov	x0, sp
	mov	x1, #\reason
	mrs	x2, esr_el1
	b	bad_mode_tlx
	.endm

el0_sync_invalid:
	inv_entry 0, BAD_SYNC
ENDPROC(el0_sync_invalid)

el0_irq_invalid:
	inv_entry 0, BAD_IRQ
ENDPROC(el0_irq_invalid)

el0_fiq_invalid:
	inv_entry 0, BAD_FIQ
ENDPROC(el0_fiq_invalid)

el0_error_invalid:
	inv_entry 0, BAD_ERROR
ENDPROC(el0_error_invalid)

#ifdef CONFIG_COMPAT
el0_fiq_invalid_compat:
	inv_entry 0, BAD_FIQ, 32
ENDPROC(el0_fiq_invalid_compat)

el0_error_invalid_compat:
	inv_entry 0, BAD_ERROR, 32
ENDPROC(el0_error_invalid_compat)
#endif

el1_sync_invalid:
	inv_entry 1, BAD_SYNC
ENDPROC(el1_sync_invalid)

el1_irq_invalid:
	inv_entry 1, BAD_IRQ
ENDPROC(el1_irq_invalid)

el1_fiq_invalid:
	inv_entry 1, BAD_FIQ
ENDPROC(el1_fiq_invalid)

el1_error_invalid:
	inv_entry 1, BAD_ERROR
ENDPROC(el1_error_invalid)

/*
 * EL1 mode handlers.
 */
	.align	6
el1_sync:
	kernel_entry 1
	mrs	x1, esr_el1			// read the syndrome register
	lsr	x24, x1, #ESR_EL1_EC_SHIFT	// exception class
	cmp	x24, #ESR_EL1_EC_DABT_EL1	// data abort in EL1
	b.eq	el1_da
	cmp	x24, #ESR_EL1_EC_SYS64		// configurable trap
	b.eq	el1_undef
	cmp	x24, #ESR_EL1_EC_SP_ALIGN	// stack alignment exception
	b.eq	el1_sp_pc
	cmp	x24, #ESR_EL1_EC_PC_ALIGN	// pc alignment exception
	b.eq	el1_sp_pc
	cmp	x24, #ESR_EL1_EC_UNKNOWN	// unknown exception in EL1
	b.eq	el1_undef
	cmp	x24, #ESR_EL1_EC_BREAKPT_EL1	// debug exception in EL1
	b.ge	el1_dbg
	b	el1_inv
el1_da:
	/*
	 * Data abort handling
	 */
	mrs	x0, far_el1
	enable_dbg
	// re-enable interrupts if they were enabled in the aborted context
	tbnz	x23, #7, 1f			// PSR_I_BIT
	enable_irq
1:
	mov	x2, sp				// struct pt_regs
	bl	do_mem_abort_tlx

	// disable interrupts before pulling preserved data off the stack
	disable_irq
	kernel_exit 1
el1_sp_pc:
	/*
	 * Stack or PC alignment exception handling
	 */
	mrs	x0, far_el1
	enable_dbg
	mov	x2, sp
	b	do_sp_pc_abort_tlx
el1_undef:
	/*
	 * Undefined instruction
	 */
	enable_dbg
	mov	x0, sp
	b	do_undefinstr_tlx
el1_dbg:
	/*
	 * Debug exception handling
	 */
	cmp	x24, #ESR_EL1_EC_BRK64		// if BRK64
	cinc	x24, x24, eq			// set bit '0'
	tbz	x24, #0, el1_inv		// EL1 only
	mrs	x0, far_el1
	mov	x2, sp				// struct pt_regs
	bl	do_debug_exception_tlx
	enable_dbg
	kernel_exit 1
el1_inv:
	// TODO: add support for undefined instructions in kernel mode
	enable_dbg
	mov	x0, sp
	mov	x1, #BAD_SYNC
	mrs	x2, esr_el1
	b	bad_mode_tlx
ENDPROC(el1_sync)

	.align	6
el1_irq:
	kernel_entry 1
	enable_dbg


	irq_handler

#ifdef CONFIG_PREEMPT
	get_thread_info tsk
	ldr	w24, [tsk, #TI_PREEMPT]		// get preempt count
	cbnz	w24, 1f				// preempt count != 0
	ldr	x0, [tsk, #TI_FLAGS]		// get flags
	tbz	x0, #TIF_NEED_RESCHED, 1f	// needs rescheduling?
	bl	el1_preempt
1:
#endif

	kernel_exit 1
ENDPROC(el1_irq)

#ifdef CONFIG_PREEMPT
el1_preempt:
	mov	x24, lr
1:	bl	preempt_schedule_irq		// irq en/disable is done inside
	ldr	x0, [tsk, #TI_FLAGS]		// get new tasks TI_FLAGS
	tbnz	x0, #TIF_NEED_RESCHED, 1b	// needs rescheduling?
	ret	x24
#endif

/*
 * EL0 mode handlers.
 */
	.align	6
el0_sync:
	kernel_entry 0
	mrs	x25, esr_el1			// read the syndrome register
	lsr	x24, x25, #ESR_EL1_EC_SHIFT	// exception class
	cmp	x24, #ESR_EL1_EC_SVC64		// SVC in 64-bit state
	b.eq	el0_svc
	adr	lr, ret_to_user
	cmp	x24, #ESR_EL1_EC_DABT_EL0	// data abort in EL0
	b.eq	el0_da
	cmp	x24, #ESR_EL1_EC_IABT_EL0	// instruction abort in EL0
	b.eq	el0_ia
	cmp	x24, #ESR_EL1_EC_FP_ASIMD	// FP/ASIMD access
	b.eq	el0_fpsimd_acc
	cmp	x24, #ESR_EL1_EC_FP_EXC64	// FP/ASIMD exception
	b.eq	el0_fpsimd_exc
	cmp	x24, #ESR_EL1_EC_SYS64		// configurable trap
	b.eq	el0_undef
	cmp	x24, #ESR_EL1_EC_SP_ALIGN	// stack alignment exception
	b.eq	el0_sp_pc
	cmp	x24, #ESR_EL1_EC_PC_ALIGN	// pc alignment exception
	b.eq	el0_sp_pc
	cmp	x24, #ESR_EL1_EC_UNKNOWN	// unknown exception in EL0
	b.eq	el0_undef
	cmp	x24, #ESR_EL1_EC_BREAKPT_EL0	// debug exception in EL0
	b.ge	el0_dbg
	b	el0_inv

#ifdef CONFIG_COMPAT
	.align	6
el0_sync_compat:
	kernel_entry 0, 32
	mrs	x25, esr_el1			// read the syndrome register
	lsr	x24, x25, #ESR_EL1_EC_SHIFT	// exception class
	cmp	x24, #ESR_EL1_EC_SVC32		// SVC in 32-bit state
	b.eq	el0_svc_compat
	adr	lr, ret_to_user
	cmp	x24, #ESR_EL1_EC_DABT_EL0	// data abort in EL0
	b.eq	el0_da
	cmp	x24, #ESR_EL1_EC_IABT_EL0	// instruction abort in EL0
	b.eq	el0_ia
	cmp	x24, #ESR_EL1_EC_FP_ASIMD	// FP/ASIMD access
	b.eq	el0_fpsimd_acc
	cmp	x24, #ESR_EL1_EC_FP_EXC32	// FP/ASIMD exception
	b.eq	el0_fpsimd_exc
	cmp	x24, #ESR_EL1_EC_UNKNOWN	// unknown exception in EL0
	b.eq	el0_undef
	cmp	x24, #ESR_EL1_EC_CP15_32	// CP15 MRC/MCR trap
	b.eq	el0_undef
	cmp	x24, #ESR_EL1_EC_CP15_64	// CP15 MRRC/MCRR trap
	b.eq	el0_undef
	cmp	x24, #ESR_EL1_EC_CP14_MR	// CP14 MRC/MCR trap
	b.eq	el0_undef
	cmp	x24, #ESR_EL1_EC_CP14_LS	// CP14 LDC/STC trap
	b.eq	el0_undef
	cmp	x24, #ESR_EL1_EC_CP14_64	// CP14 MRRC/MCRR trap
	b.eq	el0_undef
	cmp	x24, #ESR_EL1_EC_BREAKPT_EL0	// debug exception in EL0
	b.ge	el0_dbg
	b	el0_inv
el0_svc_compat:
	/*
	 * AArch32 syscall handling
	 */

	b	el0_svc_naked

	.align	6
el0_irq_compat:
	kernel_entry 0, 32
	b	el0_irq_naked
#endif

el0_da:
	/*
	 * Data abort handling
	 */
	mrs	x0, far_el1
	bic	x0, x0, #(0xff << 56)
	// enable interrupts before calling the main handler
	enable_dbg_and_irq
	mov	x1, x25
	mov	x2, sp
	b	do_mem_abort_tlx
el0_ia:
	/*
	 * Instruction abort handling
	 */
	mrs	x0, far_el1
	// enable interrupts before calling the main handler
	enable_dbg_and_irq
	orr	x1, x25, #1 << 24		// use reserved ISS bit for instruction aborts
	mov	x2, sp
	b	do_mem_abort_tlx
el0_fpsimd_acc:
	/*
	 * Floating Point or Advanced SIMD access
	 */
	enable_dbg
	mov	x0, x25
	mov	x1, sp
	b	do_fpsimd_acc_tlx
el0_fpsimd_exc:
el0_sp_pc:
	/*
	 * Stack or PC alignment exception handling
	 */
	mrs	x0, far_el1
	// enable interrupts before calling the main handler
	enable_dbg_and_irq
	mov	x1, x25
	mov	x2, sp
	b	do_sp_pc_abort_tlx
el0_undef:
	/*
	 * Undefined instruction
	 */
	// enable interrupts before calling the main handler
	enable_dbg_and_irq
	mov	x0, sp
	b	do_undefinstr_tlx
el0_dbg:
	/*
	 * Debug exception handling
	 */
	tbnz	x24, #0, el0_inv		// EL0 only
	mrs	x0, far_el1
	mov	x1, x25
	mov	x2, sp
	bl	do_debug_exception_tlx
	enable_dbg
	b	ret_to_user
el0_inv:
	enable_dbg
	mov	x0, sp
	mov	x1, #BAD_SYNC
	mrs	x2, esr_el1
	b	bad_mode_tlx
ENDPROC(el0_sync)

	.align	6
el0_irq:
	kernel_entry 0
el0_irq_naked:
	enable_dbg


	irq_handler


	b	ret_to_user
ENDPROC(el0_irq)

/*
 * Register switch for AArch64. The callee-saved registers need to be saved
 * and restored. On entry:
 *   x0 = previous task_struct (must be preserved across the switch)
 *   x1 = next task_struct
 * Previous and next are guaranteed not to be the same.
 *
 */
ENTRY(cpu_switch_to)
	ret
ENDPROC(cpu_switch_to)

ENTRY(cpu_switch_to_tlx)
	add	x8, x0, #THREAD_CPU_CONTEXT
	mov	x9, sp
	stp	x19, x20, [x8], #16		// store callee-saved registers
	stp	x21, x22, [x8], #16
	stp	x23, x24, [x8], #16
	stp	x25, x26, [x8], #16
	stp	x27, x28, [x8], #16
	stp	x29, x9, [x8], #16
	str	lr, [x8]
	add	x8, x1, #THREAD_CPU_CONTEXT
	ldp	x19, x20, [x8], #16		// restore callee-saved registers
	ldp	x21, x22, [x8], #16
	ldp	x23, x24, [x8], #16
	ldp	x25, x26, [x8], #16
	ldp	x27, x28, [x8], #16
	ldp	x29, x9, [x8], #16
	ldr	lr, [x8]
	mov	sp, x9
	ret
ENDPROC(cpu_switch_to_tlx)

/*
 * This is the fast syscall return path.  We do as little as possible here,
 * and this includes saving x0 back into the kernel stack.
 */
ret_fast_syscall:
	disable_irq				// disable interrupts
	ldr	x1, [tsk, #TI_FLAGS]
	and	x2, x1, #_TIF_WORK_MASK
	cbnz	x2, fast_work_pending
	enable_step_tsk x1, x2
	kernel_exit 0, ret = 1

/*
 * Ok, we need to do extra processing, enter the slow path.
 */
fast_work_pending:
	str	x0, [sp, #S_X0]			// returned x0
work_pending:
	tbnz	x1, #TIF_NEED_RESCHED, work_resched
	/* TIF_SIGPENDING, TIF_NOTIFY_RESUME or TIF_FOREIGN_FPSTATE case */
	ldr	x2, [sp, #S_PSTATE]
	mov	x0, sp				// 'regs'
	tst	x2, #PSR_MODE_MASK		// user mode regs?
	b.ne	no_work_pending			// returning to kernel
	enable_irq				// enable interrupts for do_notify_resume()
	bl	do_notify_resume_tlx
	b	ret_to_user
work_resched:
	bl	__schedule_tlx

/*
 * "slow" syscall return path.
 */
ret_to_user:
	disable_irq				// disable interrupts
	ldr	x1, [tsk, #TI_FLAGS]
	and	x2, x1, #_TIF_WORK_MASK
	cbnz	x2, work_pending
	enable_step_tsk x1, x2
no_work_pending:
	kernel_exit 0, ret = 0
ENDPROC(ret_to_user)

/*
 * This is how we return from a fork.
 */
ENTRY(ret_from_fork)
	bl	schedule_tail_tlx
	cbz	x19, 1f				// not a kernel thread
	mov	x0, x20
	blr	x19
1:	get_thread_info tsk
  disable_irq				// disable interrupts
  ldr	x1, [tsk, #TI_FLAGS]
  and	x2, x1, #_TIF_WORK_MASK
  cbnz	x2, work_pending
  enable_step_tsk x1, x2
  kernel_exit 0, ret = 0
ENDPROC(ret_from_fork)

ENTRY(ret_from_fork_tlx)
	bl	schedule_tail_tlx
	cbz	x19, 1f				// not a kernel thread
	mov	x0, x20
	blr	x19
1:	get_thread_info tsk
  disable_irq				// disable interrupts
  ldr	x1, [tsk, #TI_FLAGS]
  and	x2, x1, #_TIF_WORK_MASK
  cbnz	x2, work_pending
  enable_step_tsk x1, x2
  kernel_exit 0, ret = 0
ENDPROC(ret_from_fork_tlx)

/*
 * SVC handler.
 */
	.align	6
el0_svc:
	adrp	stbl, sys_call_table_tlx		// load syscall table pointer
	uxtw	scno, w8			// syscall number in w8
	mov	sc_nr, #__NR_syscalls
el0_svc_naked:					// compat entry point
	stp	x0, scno, [sp, #S_ORIG_X0]	// save the original x0 and syscall number
	enable_dbg_and_irq
	adr	lr, ret_fast_syscall		// return address
	cmp     scno, sc_nr                     // check upper syscall limit
	b.hs	ni_sys
	ldr	x16, [stbl, scno, lsl #3]	// address in the syscall table
	br	x16				// call sys_* routine
ni_sys:
	mov	x0, sp
ENDPROC(el0_svc)

/*
 * Special system call wrappers.
 */
ENTRY(sys_rt_sigreturn_wrapper)
	mov	x0, sp
ENDPROC(sys_rt_sigreturn_wrapper)

#define USER(l, x...)				\
9999:	x;					\
  .section __ex_table,"a";		\
  .align	3;				\
  .quad	9999b,l;			\
  .previous

ENTRY(__copy_to_user_tlx)
  add	x4, x0, x2			// upper user buffer boundary
  subs	x2, x2, #8
  b.mi	2f
1:
  ldr	x3, [x1], #8
  subs	x2, x2, #8
USER(9f, str	x3, [x0], #8	)
  b.pl	1b
2:	adds	x2, x2, #4
  b.mi	3f
  ldr	w3, [x1], #4
  sub	x2, x2, #4
USER(9f, str	w3, [x0], #4	)
3:	adds	x2, x2, #2
  b.mi	4f
  ldrh	w3, [x1], #2
  sub	x2, x2, #2
USER(9f, strh	w3, [x0], #2	)
4:	adds	x2, x2, #1
  b.mi	5f
  ldrb	w3, [x1]
USER(9f, strb	w3, [x0]	)
5:	mov	x0, #0
  ret
ENDPROC(__copy_to_user_tlx)

.section .fixup,"ax"
.align	2
9:	sub	x0, x4, x0			// bytes not copied
ret
.previous

ENTRY(handle_arch_irq_tlx)
	.quad	0


__PAGE_ALIGNED_DATA

.globl vdso_start_tlx, vdso_end_tlx
.balign PAGE_SIZE
vdso_start_tlx:
.incbin "arch/arm64/kernel/vdso/vdso.so"
.balign PAGE_SIZE
vdso_end_tlx:

.previous


.section .init.ramfs,"a"
__irf_start_tlx:
.incbin "usr/initramfs_data.cpio.gz"
__irf_end_tlx:
.section .init.ramfs.info,"a"
.globl VMLINUX_SYMBOL(__initramfs_size_tlx)
VMLINUX_SYMBOL(__initramfs_size_tlx):
#ifdef CONFIG_64BIT
	.quad __irf_end_tlx - __irf_start_tlx
#else
	.long __irf_end_tlx - __irf_start_tlx
#endif

.macro fpsimd_restore state, tmpnr
  ldp	q0, q1, [\state, #16 * 0]
  ldp	q2, q3, [\state, #16 * 2]
  ldp	q4, q5, [\state, #16 * 4]
  ldp	q6, q7, [\state, #16 * 6]
  ldp	q8, q9, [\state, #16 * 8]
  ldp	q10, q11, [\state, #16 * 10]
  ldp	q12, q13, [\state, #16 * 12]
  ldp	q14, q15, [\state, #16 * 14]
  ldp	q16, q17, [\state, #16 * 16]
  ldp	q18, q19, [\state, #16 * 18]
  ldp	q20, q21, [\state, #16 * 20]
  ldp	q22, q23, [\state, #16 * 22]
  ldp	q24, q25, [\state, #16 * 24]
  ldp	q26, q27, [\state, #16 * 26]
  ldp	q28, q29, [\state, #16 * 28]
  ldp	q30, q31, [\state, #16 * 30]!
  ldr	w\tmpnr, [\state, #16 * 2]
  msr	fpsr, x\tmpnr
  ldr	w\tmpnr, [\state, #16 * 2 + 4]
  msr	fpcr, x\tmpnr
.endm

ENTRY(fpsimd_load_state_tlx)
  fpsimd_restore x0, 8
  ret
ENDPROC(fpsimd_load_state_tlx)


ENTRY(cpu_do_idle_tlx)
	dsb	sy				// WFI may enter a low-power mode
	wfi
	ret
ENDPROC(cpu_do_idle_tlx)


#define MM_CONTEXT_ID 688


	.macro	mmid, rd, rn
	ldr	\rd, [\rn, #MM_CONTEXT_ID]
	.endm

ENTRY(cpu_do_switch_mm_tlx)
	mmid	w1, x1				// get mm->context.id
	bfi	x0, x1, #48, #16		// set the ASID
	msr	ttbr0_el1, x0			// set TTBR0
	isb
	ret
ENDPROC(cpu_do_switch_mm_tlx)

#define REP8_01 0x0101010101010101
#define REP8_7f 0x7f7f7f7f7f7f7f7f
#define REP8_80 0x8080808080808080

/* Parameters and result.  */
src1		.req	x0
src2		.req	x1
result		.req	x0

/* Internal variables.  */
data1		.req	x2
data1w		.req	w2
data2		.req	x3
data2w		.req	w3
has_nul		.req	x4
diff		.req	x5
syndrome	.req	x6
tmp1		.req	x7
tmp2		.req	x8
tmp3		.req	x9
zeroones	.req	x10
pos		.req	x11

#define CPU_BE(code...)

#define CPU_LE(code...) code


ENTRY(strcmp_tlx)
	eor	tmp1, src1, src2
	mov	zeroones, #REP8_01
	tst	tmp1, #7
	b.ne	.Lmisaligned8
	ands	tmp1, src1, #7
	b.ne	.Lmutual_align

	/*
	* NUL detection works on the principle that (X - 1) & (~X) & 0x80
	* (=> (X - 1) & ~(X | 0x7f)) is non-zero iff a byte is zero, and
	* can be done in parallel across the entire word.
	*/
.Lloop_aligned:
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8
.Lstart_realigned:
	sub	tmp1, data1, zeroones
	orr	tmp2, data1, #REP8_7f
	eor	diff, data1, data2	/* Non-zero if differences found.  */
	bic	has_nul, tmp1, tmp2	/* Non-zero if NUL terminator.  */
	orr	syndrome, diff, has_nul
	cbz	syndrome, .Lloop_aligned
	b	.Lcal_cmpresult

.Lmutual_align:
	/*
	* Sources are mutually aligned, but are not currently at an
	* alignment boundary.  Round down the addresses and then mask off
	* the bytes that preceed the start point.
	*/
	bic	src1, src1, #7
	bic	src2, src2, #7
	lsl	tmp1, tmp1, #3		/* Bytes beyond alignment -> bits.  */
	ldr	data1, [src1], #8
	neg	tmp1, tmp1		/* Bits to alignment -64.  */
	ldr	data2, [src2], #8
	mov	tmp2, #~0
	/* Big-endian.  Early bytes are at MSB.  */
CPU_BE( lsl	tmp2, tmp2, tmp1 )	/* Shift (tmp1 & 63).  */
	/* Little-endian.  Early bytes are at LSB.  */
CPU_LE( lsr	tmp2, tmp2, tmp1 )	/* Shift (tmp1 & 63).  */

	orr	data1, data1, tmp2
	orr	data2, data2, tmp2
	b	.Lstart_realigned

.Lmisaligned8:
	/*
	* Get the align offset length to compare per byte first.
	* After this process, one string's address will be aligned.
	*/
	and	tmp1, src1, #7
	neg	tmp1, tmp1
	add	tmp1, tmp1, #8
	and	tmp2, src2, #7
	neg	tmp2, tmp2
	add	tmp2, tmp2, #8
	subs	tmp3, tmp1, tmp2
	csel	pos, tmp1, tmp2, hi /*Choose the maximum. */
.Ltinycmp:
	ldrb	data1w, [src1], #1
	ldrb	data2w, [src2], #1
	subs	pos, pos, #1
	ccmp	data1w, #1, #0, ne  /* NZCV = 0b0000.  */
	ccmp	data1w, data2w, #0, cs  /* NZCV = 0b0000.  */
	b.eq	.Ltinycmp
	cbnz	pos, 1f /*find the null or unequal...*/
	cmp	data1w, #1
	ccmp	data1w, data2w, #0, cs
	b.eq	.Lstart_align /*the last bytes are equal....*/
1:
	sub	result, data1, data2
	ret

.Lstart_align:
	ands	xzr, src1, #7
	b.eq	.Lrecal_offset
	/*process more leading bytes to make str1 aligned...*/
	add	src1, src1, tmp3
	add	src2, src2, tmp3
	/*load 8 bytes from aligned str1 and non-aligned str2..*/
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8

	sub	tmp1, data1, zeroones
	orr	tmp2, data1, #REP8_7f
	bic	has_nul, tmp1, tmp2
	eor	diff, data1, data2 /* Non-zero if differences found.  */
	orr	syndrome, diff, has_nul
	cbnz	syndrome, .Lcal_cmpresult
	/*How far is the current str2 from the alignment boundary...*/
	and	tmp3, tmp3, #7
.Lrecal_offset:
	neg	pos, tmp3
.Lloopcmp_proc:
	/*
	* Divide the eight bytes into two parts. First,backwards the src2
	* to an alignment boundary,load eight bytes from the SRC2 alignment
	* boundary,then compare with the relative bytes from SRC1.
	* If all 8 bytes are equal,then start the second part's comparison.
	* Otherwise finish the comparison.
	* This special handle can garantee all the accesses are in the
	* thread/task space in avoid to overrange access.
	*/
	ldr	data1, [src1,pos]
	ldr	data2, [src2,pos]
	sub	tmp1, data1, zeroones
	orr	tmp2, data1, #REP8_7f
	bic	has_nul, tmp1, tmp2
	eor	diff, data1, data2  /* Non-zero if differences found.  */
	orr	syndrome, diff, has_nul
	cbnz	syndrome, .Lcal_cmpresult

	/*The second part process*/
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8
	sub	tmp1, data1, zeroones
	orr	tmp2, data1, #REP8_7f
	bic	has_nul, tmp1, tmp2
	eor	diff, data1, data2  /* Non-zero if differences found.  */
	orr	syndrome, diff, has_nul
	cbz	syndrome, .Lloopcmp_proc

.Lcal_cmpresult:
	/*
	* reversed the byte-order as big-endian,then CLZ can find the most
	* significant zero bits.
	*/
CPU_LE( rev	syndrome, syndrome )
CPU_LE( rev	data1, data1 )
CPU_LE( rev	data2, data2 )

	/*
	* For big-endian we cannot use the trick with the syndrome value
	* as carry-propagation can corrupt the upper bits if the trailing
	* bytes in the string contain 0x01.
	* However, if there is no NUL byte in the dword, we can generate
	* the result directly.  We ca not just subtract the bytes as the
	* MSB might be significant.
	*/
CPU_BE( cbnz	has_nul, 1f )
CPU_BE( cmp	data1, data2 )
CPU_BE( cset	result, ne )
CPU_BE( cneg	result, result, lo )
CPU_BE( ret )
CPU_BE( 1: )
	/*Re-compute the NUL-byte detection, using a byte-reversed value. */
CPU_BE(	rev	tmp3, data1 )
CPU_BE(	sub	tmp1, tmp3, zeroones )
CPU_BE(	orr	tmp2, tmp3, #REP8_7f )
CPU_BE(	bic	has_nul, tmp1, tmp2 )
CPU_BE(	rev	has_nul, has_nul )
CPU_BE(	orr	syndrome, diff, has_nul )

	clz	pos, syndrome
	/*
	* The MS-non-zero bit of the syndrome marks either the first bit
	* that is different, or the top bit of the first zero byte.
	* Shifting left now will bring the critical information into the
	* top bits.
	*/
	lsl	data1, data1, pos
	lsl	data2, data2, pos
	/*
	* But we need to zero-extend (char is unsigned) the value and then
	* perform a signed 32-bit subtraction.
	*/
	lsr	data1, data1, #56
	sub	result, data1, data2, lsr #56
	ret
ENDPROC(strcmp_tlx)

#define REP8_01 0x0101010101010101
#define REP8_7f 0x7f7f7f7f7f7f7f7f
#define REP8_80 0x8080808080808080

/* Parameters and result.  */
src1		.req	x0
src2		.req	x1
limit		.req	x2
result		.req	x0

/* Internal variables.  */
data1		.req	x3
data1w		.req	w3
data2		.req	x4
data2w		.req	w4
has_nul		.req	x5
diff		.req	x6
syndrome	.req	x7
tmp1		.req	x8
tmp2		.req	x9
tmp3		.req	x10
zeroones	.req	x11
pos		.req	x12
limit_wd	.req	x13
mask		.req	x14
endloop		.req	x15

ENTRY(strncmp_tlx)
	cbz	limit, .Lret0
	eor	tmp1, src1, src2
	mov	zeroones, #REP8_01
	tst	tmp1, #7
	b.ne	.Lmisaligned8_2
	ands	tmp1, src1, #7
	b.ne	.Lmutual_align
	/* Calculate the number of full and partial words -1.  */
	/*
	* when limit is mulitply of 8, if not sub 1,
	* the judgement of last dword will wrong.
	*/
	sub	limit_wd, limit, #1 /* limit != 0, so no underflow.  */
	lsr	limit_wd, limit_wd, #3  /* Convert to Dwords.  */

	/*
	* NUL detection works on the principle that (X - 1) & (~X) & 0x80
	* (=> (X - 1) & ~(X | 0x7f)) is non-zero iff a byte is zero, and
	* can be done in parallel across the entire word.
	*/
.Lloop_aligned2:
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8
.Lstart_realigned2:
	subs	limit_wd, limit_wd, #1
	sub	tmp1, data1, zeroones
	orr	tmp2, data1, #REP8_7f
	eor	diff, data1, data2  /* Non-zero if differences found.  */
	csinv	endloop, diff, xzr, pl  /* Last Dword or differences.*/
	bics	has_nul, tmp1, tmp2 /* Non-zero if NUL terminator.  */
	ccmp	endloop, #0, #0, eq
	b.eq	.Lloop_aligned2

	/*Not reached the limit, must have found the end or a diff.  */
	tbz	limit_wd, #63, .Lnot_limit

	/* Limit % 8 == 0 => all bytes significant.  */
	ands	limit, limit, #7
	b.eq	.Lnot_limit

	lsl	limit, limit, #3    /* Bits -> bytes.  */
	mov	mask, #~0
CPU_BE( lsr	mask, mask, limit )
CPU_LE( lsl	mask, mask, limit )
	bic	data1, data1, mask
	bic	data2, data2, mask

	/* Make sure that the NUL byte is marked in the syndrome.  */
	orr	has_nul, has_nul, mask

.Lnot_limit:
	orr	syndrome, diff, has_nul
	b	.Lcal_cmpresult2

.Lmutual_align2:
	/*
	* Sources are mutually aligned, but are not currently at an
	* alignment boundary.  Round down the addresses and then mask off
	* the bytes that precede the start point.
	* We also need to adjust the limit calculations, but without
	* overflowing if the limit is near ULONG_MAX.
	*/
	bic	src1, src1, #7
	bic	src2, src2, #7
	ldr	data1, [src1], #8
	neg	tmp3, tmp1, lsl #3  /* 64 - bits(bytes beyond align). */
	ldr	data2, [src2], #8
	mov	tmp2, #~0
	sub	limit_wd, limit, #1 /* limit != 0, so no underflow.  */
	/* Big-endian.  Early bytes are at MSB.  */
CPU_BE( lsl	tmp2, tmp2, tmp3 )	/* Shift (tmp1 & 63).  */
	/* Little-endian.  Early bytes are at LSB.  */
CPU_LE( lsr	tmp2, tmp2, tmp3 )	/* Shift (tmp1 & 63).  */

	and	tmp3, limit_wd, #7
	lsr	limit_wd, limit_wd, #3
	/* Adjust the limit. Only low 3 bits used, so overflow irrelevant.*/
	add	limit, limit, tmp1
	add	tmp3, tmp3, tmp1
	orr	data1, data1, tmp2
	orr	data2, data2, tmp2
	add	limit_wd, limit_wd, tmp3, lsr #3
	b	.Lstart_realigned2

/*when src1 offset is not equal to src2 offset...*/
.Lmisaligned8_2:
	cmp	limit, #8
	b.lo	.Ltiny8proc /*limit < 8... */
	/*
	* Get the align offset length to compare per byte first.
	* After this process, one string's address will be aligned.*/
	and	tmp1, src1, #7
	neg	tmp1, tmp1
	add	tmp1, tmp1, #8
	and	tmp2, src2, #7
	neg	tmp2, tmp2
	add	tmp2, tmp2, #8
	subs	tmp3, tmp1, tmp2
	csel	pos, tmp1, tmp2, hi /*Choose the maximum. */
	/*
	* Here, limit is not less than 8, so directly run .Ltinycmp
	* without checking the limit.*/
	sub	limit, limit, pos
.Ltinycmp_2:
	ldrb	data1w, [src1], #1
	ldrb	data2w, [src2], #1
	subs	pos, pos, #1
	ccmp	data1w, #1, #0, ne  /* NZCV = 0b0000.  */
	ccmp	data1w, data2w, #0, cs  /* NZCV = 0b0000.  */
	b.eq	.Ltinycmp_2
	cbnz	pos, 1f /*find the null or unequal...*/
	cmp	data1w, #1
	ccmp	data1w, data2w, #0, cs
	b.eq	.Lstart_align2 /*the last bytes are equal....*/
1:
	sub	result, data1, data2
	ret

.Lstart_align2:
	lsr	limit_wd, limit, #3
	cbz	limit_wd, .Lremain8
	/*process more leading bytes to make str1 aligned...*/
	ands	xzr, src1, #7
	b.eq	.Lrecal_offset2
	add	src1, src1, tmp3	/*tmp3 is positive in this branch.*/
	add	src2, src2, tmp3
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8

	sub	limit, limit, tmp3
	lsr	limit_wd, limit, #3
	subs	limit_wd, limit_wd, #1

	sub	tmp1, data1, zeroones
	orr	tmp2, data1, #REP8_7f
	eor	diff, data1, data2  /* Non-zero if differences found.  */
	csinv	endloop, diff, xzr, ne/*if limit_wd is 0,will finish the cmp*/
	bics	has_nul, tmp1, tmp2
	ccmp	endloop, #0, #0, eq /*has_null is ZERO: no null byte*/
	b.ne	.Lunequal_proc
	/*How far is the current str2 from the alignment boundary...*/
	and	tmp3, tmp3, #7
.Lrecal_offset2:
	neg	pos, tmp3
.Lloopcmp_proc2:
	/*
	* Divide the eight bytes into two parts. First,backwards the src2
	* to an alignment boundary,load eight bytes from the SRC2 alignment
	* boundary,then compare with the relative bytes from SRC1.
	* If all 8 bytes are equal,then start the second part's comparison.
	* Otherwise finish the comparison.
	* This special handle can garantee all the accesses are in the
	* thread/task space in avoid to overrange access.
	*/
	ldr	data1, [src1,pos]
	ldr	data2, [src2,pos]
	sub	tmp1, data1, zeroones
	orr	tmp2, data1, #REP8_7f
	bics	has_nul, tmp1, tmp2 /* Non-zero if NUL terminator.  */
	eor	diff, data1, data2  /* Non-zero if differences found.  */
	csinv	endloop, diff, xzr, eq
	cbnz	endloop, .Lunequal_proc

	/*The second part process*/
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8
	subs	limit_wd, limit_wd, #1
	sub	tmp1, data1, zeroones
	orr	tmp2, data1, #REP8_7f
	eor	diff, data1, data2  /* Non-zero if differences found.  */
	csinv	endloop, diff, xzr, ne/*if limit_wd is 0,will finish the cmp*/
	bics	has_nul, tmp1, tmp2
	ccmp	endloop, #0, #0, eq /*has_null is ZERO: no null byte*/
	b.eq	.Lloopcmp_proc2

.Lunequal_proc:
	orr	syndrome, diff, has_nul
	cbz	syndrome, .Lremain8
.Lcal_cmpresult2:
	/*
	* reversed the byte-order as big-endian,then CLZ can find the most
	* significant zero bits.
	*/
CPU_LE( rev	syndrome, syndrome )
CPU_LE( rev	data1, data1 )
CPU_LE( rev	data2, data2 )
	/*
	* For big-endian we cannot use the trick with the syndrome value
	* as carry-propagation can corrupt the upper bits if the trailing
	* bytes in the string contain 0x01.
	* However, if there is no NUL byte in the dword, we can generate
	* the result directly.  We can't just subtract the bytes as the
	* MSB might be significant.
	*/
CPU_BE( cbnz	has_nul, 1f )
CPU_BE( cmp	data1, data2 )
CPU_BE( cset	result, ne )
CPU_BE( cneg	result, result, lo )
CPU_BE( ret )
CPU_BE( 1: )
	/* Re-compute the NUL-byte detection, using a byte-reversed value.*/
CPU_BE( rev	tmp3, data1 )
CPU_BE( sub	tmp1, tmp3, zeroones )
CPU_BE( orr	tmp2, tmp3, #REP8_7f )
CPU_BE( bic	has_nul, tmp1, tmp2 )
CPU_BE( rev	has_nul, has_nul )
CPU_BE( orr	syndrome, diff, has_nul )
	/*
	* The MS-non-zero bit of the syndrome marks either the first bit
	* that is different, or the top bit of the first zero byte.
	* Shifting left now will bring the critical information into the
	* top bits.
	*/
	clz	pos, syndrome
	lsl	data1, data1, pos
	lsl	data2, data2, pos
	/*
	* But we need to zero-extend (char is unsigned) the value and then
	* perform a signed 32-bit subtraction.
	*/
	lsr	data1, data1, #56
	sub	result, data1, data2, lsr #56
	ret

.Lremain8:
	/* Limit % 8 == 0 => all bytes significant.  */
	ands	limit, limit, #7
	b.eq	.Lret0
.Ltiny8proc:
	ldrb	data1w, [src1], #1
	ldrb	data2w, [src2], #1
	subs	limit, limit, #1

	ccmp	data1w, #1, #0, ne  /* NZCV = 0b0000.  */
	ccmp	data1w, data2w, #0, cs  /* NZCV = 0b0000.  */
	b.eq	.Ltiny8proc
	sub	result, data1, data2
	ret

.Lret0:
	mov	result, #0
	ret
ENDPROC(strncmp_tlx)

srcin		.req	x0
len		.req	x0

/* Locals and temporaries.  */
src		.req	x1
data1		.req	x2
data2		.req	x3
data2a		.req	x4
has_nul1	.req	x5
has_nul2	.req	x6
tmp1		.req	x7
tmp2		.req	x8
tmp3		.req	x9
tmp4		.req	x10
zeroones	.req	x11
pos		.req	x12

#define REP8_01 0x0101010101010101
#define REP8_7f 0x7f7f7f7f7f7f7f7f
#define REP8_80 0x8080808080808080





ENTRY(strlen_tlx)
	mov	zeroones, #REP8_01
	bic	src, srcin, #15
	ands	tmp1, srcin, #15
	b.ne	.Lmisaligned
	/*
	* NUL detection works on the principle that (X - 1) & (~X) & 0x80
	* (=> (X - 1) & ~(X | 0x7f)) is non-zero iff a byte is zero, and
	* can be done in parallel across the entire word.
	*/
	/*
	* The inner loop deals with two Dwords at a time. This has a
	* slightly higher start-up cost, but we should win quite quickly,
	* especially on cores with a high number of issue slots per
	* cycle, as we get much better parallelism out of the operations.
	*/
.Lloop:
	ldp	data1, data2, [src], #16
.Lrealigned:
	sub	tmp1, data1, zeroones
	orr	tmp2, data1, #REP8_7f
	sub	tmp3, data2, zeroones
	orr	tmp4, data2, #REP8_7f
	bic	has_nul1, tmp1, tmp2
	bics	has_nul2, tmp3, tmp4
	ccmp	has_nul1, #0, #0, eq	/* NZCV = 0000  */
	b.eq	.Lloop

	sub	len, src, srcin
	cbz	has_nul1, .Lnul_in_data2
CPU_BE(	mov	data2, data1 )	/*prepare data to re-calculate the syndrome*/
	sub	len, len, #8
	mov	has_nul2, has_nul1
.Lnul_in_data2:
	/*
	* For big-endian, carry propagation (if the final byte in the
	* string is 0x01) means we cannot use has_nul directly.  The
	* easiest way to get the correct byte is to byte-swap the data
	* and calculate the syndrome a second time.
	*/
CPU_BE( rev	data2, data2 )
CPU_BE( sub	tmp1, data2, zeroones )
CPU_BE( orr	tmp2, data2, #REP8_7f )
CPU_BE( bic	has_nul2, tmp1, tmp2 )

	sub	len, len, #8
	rev	has_nul2, has_nul2
	clz	pos, has_nul2
	add	len, len, pos, lsr #3		/* Bits to bytes.  */
	ret

.Lmisaligned:
	cmp	tmp1, #8
	neg	tmp1, tmp1
	ldp	data1, data2, [src], #16
	lsl	tmp1, tmp1, #3		/* Bytes beyond alignment -> bits.  */
	mov	tmp2, #~0
	/* Big-endian.  Early bytes are at MSB.  */
CPU_BE( lsl	tmp2, tmp2, tmp1 )	/* Shift (tmp1 & 63).  */
	/* Little-endian.  Early bytes are at LSB.  */
CPU_LE( lsr	tmp2, tmp2, tmp1 )	/* Shift (tmp1 & 63).  */

	orr	data1, data1, tmp2
	orr	data2a, data2, tmp2
	csinv	data1, data1, xzr, le
	csel	data2, data2, data2a, le
	b	.Lrealigned
ENDPROC(strlen_tlx)

#define L1_CACHE_SHIFT		6

dstin2	.req	x0
src2	.req	x1
count2	.req	x2
tmp1_2	.req	x3
tmp1_2w	.req	w3
tmp_22	.req	x4
tmp_22w	.req	w4
tmp3_2	.req	x5
tmp3_2w	.req	w5
dst_2	.req	x6

A_l	.req	x7
A_h	.req	x8
B_l	.req	x9
B_h	.req	x10
C_l	.req	x11
C_h	.req	x12
D_l	.req	x13
D_h	.req	x14

ENTRY(memcpy_tlx)
	mov	dst_2, dstin2
	cmp	count2, #16
	/*When memory length is less than 16, the accessed are not aligned.*/
	b.lo	.Ltiny15

	neg	tmp_22, src2
	ands	tmp_22, tmp_22, #15/* Bytes to reach alignment. */
	b.eq	.Lsrc2Aligned
	sub	count2, count2, tmp_22
	/*
	* Copy the leading memory data from src2 to dst_2 in an increasing
	* address order.By this way,the risk of overwritting the source
	* memory data is eliminated when the distance between src2 and
	* dst_2 is less than 16. The memory accesses here are alignment.
	*/
	tbz	tmp_22, #0, 1f
	ldrb	tmp1_2w, [src2], #1
	strb	tmp1_2w, [dst_2], #1
1:
	tbz	tmp_22, #1, 2f
	ldrh	tmp1_2w, [src2], #2
	strh	tmp1_2w, [dst_2], #2
2:
	tbz	tmp_22, #2, 3f
	ldr	tmp1_2w, [src2], #4
	str	tmp1_2w, [dst_2], #4
3:
	tbz	tmp_22, #3, .Lsrc2Aligned
	ldr	tmp1_2, [src2],#8
	str	tmp1_2, [dst_2],#8

.Lsrc2Aligned:
	cmp	count2, #64
	b.ge	.Lcpy_over64
	/*
	* Deal with small copies quickly by dropping straight into the
	* exit block.
	*/
.Ltail63:
	/*
	* Copy up to 48 bytes of data. At this point we only need the
	* bottom 6 bits of count2 to be accurate.
	*/
	ands	tmp1_2, count2, #0x30
	b.eq	.Ltiny15
	cmp	tmp1_2w, #0x20
	b.eq	1f
	b.lt	2f
	ldp	A_l, A_h, [src2], #16
	stp	A_l, A_h, [dst_2], #16
1:
	ldp	A_l, A_h, [src2], #16
	stp	A_l, A_h, [dst_2], #16
2:
	ldp	A_l, A_h, [src2], #16
	stp	A_l, A_h, [dst_2], #16
.Ltiny15:
	/*
	* Prefer to break one ldp/stp into several load/store to access
	* memory in an increasing address order,rather than to load/store 16
	* bytes from (src2-16) to (dst_2-16) and to backward the src2 to aligned
	* address,which way is used in original cortex memcpy. If keeping
	* the original memcpy process here, memmove need to satisfy the
	* precondition that src2 address is at least 16 bytes bigger than dst_2
	* address,otherwise some source data will be overwritten when memove
	* call memcpy directly. To make memmove simpler and decouple the
	* memcpy's dependency on memmove, withdrew the original process.
	*/
	tbz	count2, #3, 1f
	ldr	tmp1_2, [src2], #8
	str	tmp1_2, [dst_2], #8
1:
	tbz	count2, #2, 2f
	ldr	tmp1_2w, [src2], #4
	str	tmp1_2w, [dst_2], #4
2:
	tbz	count2, #1, 3f
	ldrh	tmp1_2w, [src2], #2
	strh	tmp1_2w, [dst_2], #2
3:
	tbz	count2, #0, .Lexitfunc
	ldrb	tmp1_2w, [src2]
	strb	tmp1_2w, [dst_2]

.Lexitfunc:
	ret

.Lcpy_over64:
	subs	count2, count2, #128
	b.ge	.Lcpy_body_large
	/*
	* Less than 128 bytes to copy, so handle 64 here and then jump
	* to the tail.
	*/
	ldp	A_l, A_h, [src2],#16
	stp	A_l, A_h, [dst_2],#16
	ldp	B_l, B_h, [src2],#16
	ldp	C_l, C_h, [src2],#16
	stp	B_l, B_h, [dst_2],#16
	stp	C_l, C_h, [dst_2],#16
	ldp	D_l, D_h, [src2],#16
	stp	D_l, D_h, [dst_2],#16

	tst	count2, #0x3f
	b.ne	.Ltail63
	ret

	/*
	* Critical loop.  Start at a new cache line boundary.  Assuming
	* 64 bytes per line this ensures the entire loop is in one line.
	*/
	.p2align	L1_CACHE_SHIFT
.Lcpy_body_large:
	/* pre-get 64 bytes data. */
	ldp	A_l, A_h, [src2],#16
	ldp	B_l, B_h, [src2],#16
	ldp	C_l, C_h, [src2],#16
	ldp	D_l, D_h, [src2],#16
1:
	/*
	* interlace the load of next 64 bytes data block with store of the last
	* loaded 64 bytes data.
	*/
	stp	A_l, A_h, [dst_2],#16
	ldp	A_l, A_h, [src2],#16
	stp	B_l, B_h, [dst_2],#16
	ldp	B_l, B_h, [src2],#16
	stp	C_l, C_h, [dst_2],#16
	ldp	C_l, C_h, [src2],#16
	stp	D_l, D_h, [dst_2],#16
	ldp	D_l, D_h, [src2],#16
	subs	count2, count2, #64
	b.ge	1b
	stp	A_l, A_h, [dst_2],#16
	stp	B_l, B_h, [dst_2],#16
	stp	C_l, C_h, [dst_2],#16
	stp	D_l, D_h, [dst_2],#16

	tst	count2, #0x3f
	b.ne	.Ltail63
	ret
ENDPROC(memcpy_tlx)


dstin3	.req	x0
src3	.req	x1
count3	.req	x2
tmp1_3	.req	x3
tmp1_3w	.req	w3
tmp2_3	.req	x4
tmp2_3w	.req	w4
tmp3_3	.req	x5
tmp3_3w	.req	w5
dst_3	.req	x6

A_l	.req	x7
A_h	.req	x8
B_l	.req	x9
B_h	.req	x10
C_l	.req	x11
C_h	.req	x12
D_l	.req	x13
D_h	.req	x14

ENTRY(memmove_tlx)
	cmp	dstin3, src3
	b.lo	memcpy_tlx
	add	tmp1_3, src3, count3
	cmp	dstin3, tmp1_3
	b.hs	memcpy_tlx		/* No overlap.  */

	add	dst_3, dstin3, count3
	add	src3, src3, count3
	cmp	count3, #16
	b.lo	.Ltail15  /*probably non-alignment accesses.*/

	ands	tmp2_3, src3, #15     /* Bytes to reach alignment.  */
	b.eq	.Lsrc3Aligned
	sub	count3, count3, tmp2_3
	/*
	* process the aligned offset length to make the src3 aligned firstly.
	* those extra instructions' cost is acceptable. It also make the
	* coming accesses are based on aligned address.
	*/
	tbz	tmp2_3, #0, 1f
	ldrb	tmp1_3w, [src3, #-1]!
	strb	tmp1_3w, [dst_3, #-1]!
1:
	tbz	tmp2_3, #1, 2f
	ldrh	tmp1_3w, [src3, #-2]!
	strh	tmp1_3w, [dst_3, #-2]!
2:
	tbz	tmp2_3, #2, 3f
	ldr	tmp1_3w, [src3, #-4]!
	str	tmp1_3w, [dst_3, #-4]!
3:
	tbz	tmp2_3, #3, .Lsrc3Aligned
	ldr	tmp1_3, [src3, #-8]!
	str	tmp1_3, [dst_3, #-8]!

.Lsrc3Aligned:
	cmp	count3, #64
	b.ge	.Lcpy_over64_2

	/*
	* Deal with small copies quickly by dropping straight into the
	* exit block.
	*/
.Ltail63_2:
	/*
	* Copy up to 48 bytes of data. At this point we only need the
	* bottom 6 bits of count3 to be accurate.
	*/
	ands	tmp1_3, count3, #0x30
	b.eq	.Ltail15
	cmp	tmp1_3w, #0x20
	b.eq	1f
	b.lt	2f
	ldp	A_l, A_h, [src3, #-16]!
	stp	A_l, A_h, [dst_3, #-16]!
1:
	ldp	A_l, A_h, [src3, #-16]!
	stp	A_l, A_h, [dst_3, #-16]!
2:
	ldp	A_l, A_h, [src3, #-16]!
	stp	A_l, A_h, [dst_3, #-16]!

.Ltail15:
	tbz	count3, #3, 1f
	ldr	tmp1_3, [src3, #-8]!
	str	tmp1_3, [dst_3, #-8]!
1:
	tbz	count3, #2, 2f
	ldr	tmp1_3w, [src3, #-4]!
	str	tmp1_3w, [dst_3, #-4]!
2:
	tbz	count3, #1, 3f
	ldrh	tmp1_3w, [src3, #-2]!
	strh	tmp1_3w, [dst_3, #-2]!
3:
	tbz	count3, #0, .Lexitfunc_2
	ldrb	tmp1_3w, [src3, #-1]
	strb	tmp1_3w, [dst_3, #-1]

.Lexitfunc_2:
	ret

.Lcpy_over64_2:
	subs	count3, count3, #128
	b.ge	.Lcpy_body_large_2
	/*
	* Less than 128 bytes to copy, so handle 64 bytes here and then jump
	* to the tail.
	*/
	ldp	A_l, A_h, [src3, #-16]
	stp	A_l, A_h, [dst_3, #-16]
	ldp	B_l, B_h, [src3, #-32]
	ldp	C_l, C_h, [src3, #-48]
	stp	B_l, B_h, [dst_3, #-32]
	stp	C_l, C_h, [dst_3, #-48]
	ldp	D_l, D_h, [src3, #-64]!
	stp	D_l, D_h, [dst_3, #-64]!

	tst	count3, #0x3f
	b.ne	.Ltail63_2
	ret

	/*
	* Critical loop. Start at a new cache line boundary. Assuming
	* 64 bytes per line this ensures the entire loop is in one line.
	*/
	.p2align	L1_CACHE_SHIFT
.Lcpy_body_large_2:
	/* pre-load 64 bytes data. */
	ldp	A_l, A_h, [src3, #-16]
	ldp	B_l, B_h, [src3, #-32]
	ldp	C_l, C_h, [src3, #-48]
	ldp	D_l, D_h, [src3, #-64]!
1:
	/*
	* interlace the load of next 64 bytes data block with store of the last
	* loaded 64 bytes data.
	*/
	stp	A_l, A_h, [dst_3, #-16]
	ldp	A_l, A_h, [src3, #-16]
	stp	B_l, B_h, [dst_3, #-32]
	ldp	B_l, B_h, [src3, #-32]
	stp	C_l, C_h, [dst_3, #-48]
	ldp	C_l, C_h, [src3, #-48]
	stp	D_l, D_h, [dst_3, #-64]!
	ldp	D_l, D_h, [src3, #-64]!
	subs	count3, count3, #64
	b.ge	1b
	stp	A_l, A_h, [dst_3, #-16]
	stp	B_l, B_h, [dst_3, #-32]
	stp	C_l, C_h, [dst_3, #-48]
	stp	D_l, D_h, [dst_3, #-64]!

	tst	count3, #0x3f
	b.ne	.Ltail63_2
	ret
ENDPROC(memmove_tlx)


dstin3		.req	x0
val3		.req	w1
count3		.req	x2
tmp1_3		.req	x3
tmp1_3w		.req	w3
tmp2_3		.req	x4
tmp2_3w		.req	w4
zva_len_x	.req	x5
zva_len		.req	w5
zva_bits_x	.req	x6

A_l		.req	x7
A_lw		.req	w7
dst		.req	x8
tmp3w		.req	w9
tmp3		.req	x9

ENTRY(memset_tlx)
	mov	dst, dstin3	/* Preserve return val3ue.  */
	and	A_lw, val3, #255
	orr	A_lw, A_lw, A_lw, lsl #8
	orr	A_lw, A_lw, A_lw, lsl #16
	orr	A_l, A_l, A_l, lsl #32

	cmp	count3, #15
	b.hi	.Lover16_proc
	/*All store maybe are non-aligned..*/
	tbz	count3, #3, 1f
	str	A_l, [dst], #8
1:
	tbz	count3, #2, 2f
	str	A_lw, [dst], #4
2:
	tbz	count3, #1, 3f
	strh	A_lw, [dst], #2
3:
	tbz	count3, #0, 4f
	strb	A_lw, [dst]
4:
	ret

.Lover16_proc:
	/*Whether  the start address is aligned with 16.*/
	neg	tmp2_3, dst
	ands	tmp2_3, tmp2_3, #15
	b.eq	.Laligned
/*
* The count3 is not less than 16, we can use stp to store the start 16 bytes,
* then adjust the dst aligned with 16.This process will make the current
* memory address at alignment boundary.
*/
	stp	A_l, A_l, [dst] /*non-aligned store..*/
	/*make the dst aligned..*/
	sub	count3, count3, tmp2_3
	add	dst, dst, tmp2_3

.Laligned:
	cbz	A_l, .Lzero_mem

.Ltail_maybe_long:
	cmp	count3, #64
	b.ge	.Lnot_short
.Ltail63_3:
	ands	tmp1_3, count3, #0x30
	b.eq	3f
	cmp	tmp1_3w, #0x20
	b.eq	1f
	b.lt	2f
	stp	A_l, A_l, [dst], #16
1:
	stp	A_l, A_l, [dst], #16
2:
	stp	A_l, A_l, [dst], #16
/*
* The last store length is less than 16,use stp to write last 16 bytes.
* It will lead some bytes written twice and the access is non-aligned.
*/
3:
	ands	count3, count3, #15
	cbz	count3, 4f
	add	dst, dst, count3
	stp	A_l, A_l, [dst, #-16]	/* Repeat some/all of last store. */
4:
	ret

	/*
	* Critical loop. Start at a new cache line boundary. Assuming
	* 64 bytes per line, this ensures the entire loop is in one line.
	*/
	.p2align	L1_CACHE_SHIFT
.Lnot_short:
	sub	dst, dst, #16/* Pre-bias.  */
	sub	count3, count3, #64
1:
	stp	A_l, A_l, [dst, #16]
	stp	A_l, A_l, [dst, #32]
	stp	A_l, A_l, [dst, #48]
	stp	A_l, A_l, [dst, #64]!
	subs	count3, count3, #64
	b.ge	1b
	tst	count3, #0x3f
	add	dst, dst, #16
	b.ne	.Ltail63_3
.Lexitfunc_tlx:
	ret

	/*
	* For zeroing memory, check to see if we can use the ZVA feature to
	* zero entire 'cache' lines.
	*/
.Lzero_mem:
	cmp	count3, #63
	b.le	.Ltail63_3
	/*
	* For zeroing small amounts of memory, it's not worth setting up
	* the line-clear code.
	*/
	cmp	count3, #128
	b.lt	.Lnot_short /*count3 is at least  128 bytes*/

	mrs	tmp1_3, dczid_el0
	tbnz	tmp1_3, #4, .Lnot_short
	mov	tmp3w, #4
	and	zva_len, tmp1_3w, #15	/* Safety: other bits reserved.  */
	lsl	zva_len, tmp3w, zva_len

	ands	tmp3w, zva_len, #63
	/*
	* ensure the zva_len is not less than 64.
	* It is not meaningful to use ZVA if the block size is less than 64.
	*/
	b.ne	.Lnot_short
.Lzero_by_line:
	/*
	* Compute how far we need to go to become suitably aligned. We're
	* already at quad-word alignment.
	*/
	cmp	count3, zva_len_x
	b.lt	.Lnot_short		/* Not enough to reach alignment.  */
	sub	zva_bits_x, zva_len_x, #1
	neg	tmp2_3, dst
	ands	tmp2_3, tmp2_3, zva_bits_x
	b.eq	2f			/* Already aligned.  */
	/* Not aligned, check that there's enough to copy after alignment.*/
	sub	tmp1_3, count3, tmp2_3
	/*
	* grantee the remain length to be ZVA is bigger than 64,
	* avoid to make the 2f's process over mem range.*/
	cmp	tmp1_3, #64
	ccmp	tmp1_3, zva_len_x, #8, ge	/* NZCV=0b1000 */
	b.lt	.Lnot_short
	/*
	* We know that there's at least 64 bytes to zero and that it's safe
	* to overrun by 64 bytes.
	*/
	mov	count3, tmp1_3
1:
	stp	A_l, A_l, [dst]
	stp	A_l, A_l, [dst, #16]
	stp	A_l, A_l, [dst, #32]
	subs	tmp2_3, tmp2_3, #64
	stp	A_l, A_l, [dst, #48]
	add	dst, dst, #64
	b.ge	1b
	/* We've overrun a bit, so adjust dst downwards.*/
	add	dst, dst, tmp2_3
2:
	sub	count3, count3, zva_len_x
3:
	dc	zva, dst
	add	dst, dst, zva_len_x
	subs	count3, count3, zva_len_x
	b.ge	3b
	ands	count3, count3, zva_bits_x
	b.ne	.Ltail_maybe_long
	ret
ENDPROC(memset_tlx)

src1		.req	x0
src2		.req	x1
limit		.req	x2
result		.req	x0

/* Internal variables.  */
data1		.req	x3
data1w		.req	w3
data2		.req	x4
data2w		.req	w4
has_nul		.req	x5
diff		.req	x6
endloop		.req	x7
tmp1		.req	x8
tmp2		.req	x9
tmp3		.req	x10
pos		.req	x11
limit_wd	.req	x12
mask		.req	x13

ENTRY(memcmp_tlx)
	cbz	limit, .Lret0_4
	eor	tmp1, src1, src2
	tst	tmp1, #7
	b.ne	.Lmisaligned8_4
	ands	tmp1, src1, #7
	b.ne	.Lmutual_align4
	sub	limit_wd, limit, #1 /* limit != 0, so no underflow.  */
	lsr	limit_wd, limit_wd, #3 /* Convert to Dwords.  */
	/*
	* The input source addresses are at alignment boundary.
	* Directly compare eight bytes each time.
	*/
.Lloop_aligned4:
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8
.Lstart_realigned4:
	subs	limit_wd, limit_wd, #1
	eor	diff, data1, data2	/* Non-zero if differences found.  */
	csinv	endloop, diff, xzr, cs	/* Last Dword or differences.  */
	cbz	endloop, .Lloop_aligned4

	/* Not reached the limit, must have found a diff.  */
	tbz	limit_wd, #63, .Lnot_limit4

	/* Limit % 8 == 0 => the diff is in the last 8 bytes. */
	ands	limit, limit, #7
	b.eq	.Lnot_limit4
	/*
	* The remained bytes less than 8. It is needed to extract valid data
	* from last eight bytes of the intended memory range.
	*/
	lsl	limit, limit, #3	/* bytes-> bits.  */
	mov	mask, #~0
CPU_BE( lsr	mask, mask, limit )
CPU_LE( lsl	mask, mask, limit )
	bic	data1, data1, mask
	bic	data2, data2, mask

	orr	diff, diff, mask
	b	.Lnot_limit4

.Lmutual_align4:
	/*
	* Sources are mutually aligned, but are not currently at an
	* alignment boundary. Round down the addresses and then mask off
	* the bytes that precede the start point.
	*/
	bic	src1, src1, #7
	bic	src2, src2, #7
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8
	/*
	* We can not add limit with alignment offset(tmp1) here. Since the
	* addition probably make the limit overflown.
	*/
	sub	limit_wd, limit, #1/*limit != 0, so no underflow.*/
	and	tmp3, limit_wd, #7
	lsr	limit_wd, limit_wd, #3
	add	tmp3, tmp3, tmp1
	add	limit_wd, limit_wd, tmp3, lsr #3
	add	limit, limit, tmp1/* Adjust the limit for the extra.  */

	lsl	tmp1, tmp1, #3/* Bytes beyond alignment -> bits.*/
	neg	tmp1, tmp1/* Bits to alignment -64.  */
	mov	tmp2, #~0
	/*mask off the non-intended bytes before the start address.*/
CPU_BE( lsl	tmp2, tmp2, tmp1 )/*Big-endian.Early bytes are at MSB*/
	/* Little-endian.  Early bytes are at LSB.  */
CPU_LE( lsr	tmp2, tmp2, tmp1 )

	orr	data1, data1, tmp2
	orr	data2, data2, tmp2
	b	.Lstart_realigned4

	/*src1 and src2 have different alignment offset.*/
.Lmisaligned8_4:
	cmp	limit, #8
	b.lo	.Ltiny8proc_4 /*limit < 8: compare byte by byte*/

	and	tmp1, src1, #7
	neg	tmp1, tmp1
	add	tmp1, tmp1, #8/*valid length in the first 8 bytes of src1*/
	and	tmp2, src2, #7
	neg	tmp2, tmp2
	add	tmp2, tmp2, #8/*valid length in the first 8 bytes of src2*/
	subs	tmp3, tmp1, tmp2
	csel	pos, tmp1, tmp2, hi /*Choose the maximum.*/

	sub	limit, limit, pos
	/*compare the proceeding bytes in the first 8 byte segment.*/
.Ltinycmp4:
	ldrb	data1w, [src1], #1
	ldrb	data2w, [src2], #1
	subs	pos, pos, #1
	ccmp	data1w, data2w, #0, ne  /* NZCV = 0b0000.  */
	b.eq	.Ltinycmp4
	cbnz	pos, 1f /*diff occurred before the last byte.*/
	cmp	data1w, data2w
	b.eq	.Lstart_align_4
1:
	sub	result, data1, data2
	ret

.Lstart_align_4:
	lsr	limit_wd, limit, #3
	cbz	limit_wd, .Lremain8_4

	ands	xzr, src1, #7
	b.eq	.Lrecal_offset_4
	/*process more leading bytes to make src1 aligned...*/
	add	src1, src1, tmp3 /*backwards src1 to alignment boundary*/
	add	src2, src2, tmp3
	sub	limit, limit, tmp3
	lsr	limit_wd, limit, #3
	cbz	limit_wd, .Lremain8_4
	/*load 8 bytes from aligned SRC1..*/
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8

	subs	limit_wd, limit_wd, #1
	eor	diff, data1, data2  /*Non-zero if differences found.*/
	csinv	endloop, diff, xzr, ne
	cbnz	endloop, .Lunequal_proc4
	/*How far is the current SRC2 from the alignment boundary...*/
	and	tmp3, tmp3, #7

.Lrecal_offset_4:/*src1 is aligned now..*/
	neg	pos, tmp3
.Lloopcmp_proc_4:
	/*
	* Divide the eight bytes into two parts. First,backwards the src2
	* to an alignment boundary,load eight bytes and compare from
	* the SRC2 alignment boundary. If all 8 bytes are equal,then start
	* the second part's comparison. Otherwise finish the comparison.
	* This special handle can garantee all the accesses are in the
	* thread/task space in avoid to overrange access.
	*/
	ldr	data1, [src1,pos]
	ldr	data2, [src2,pos]
	eor	diff, data1, data2  /* Non-zero if differences found.  */
	cbnz	diff, .Lnot_limit4

	/*The second part process*/
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8
	eor	diff, data1, data2  /* Non-zero if differences found.  */
	subs	limit_wd, limit_wd, #1
	csinv	endloop, diff, xzr, ne/*if limit_wd is 0,will finish the cmp*/
	cbz	endloop, .Lloopcmp_proc_4
.Lunequal_proc4:
	cbz	diff, .Lremain8_4

/*There is differnence occured in the latest comparison.*/
.Lnot_limit4:
/*
* For little endian,reverse the low significant equal bits into MSB,then
* following CLZ can find how many equal bits exist.
*/
CPU_LE( rev	diff, diff )
CPU_LE( rev	data1, data1 )
CPU_LE( rev	data2, data2 )

	/*
	* The MS-non-zero bit of DIFF marks either the first bit
	* that is different, or the end of the significant data.
	* Shifting left now will bring the critical information into the
	* top bits.
	*/
	clz	pos, diff
	lsl	data1, data1, pos
	lsl	data2, data2, pos
	/*
	* We need to zero-extend (char is unsigned) the value and then
	* perform a signed subtraction.
	*/
	lsr	data1, data1, #56
	sub	result, data1, data2, lsr #56
	ret

.Lremain8_4:
	/* Limit % 8 == 0 =>. all data are equal.*/
	ands	limit, limit, #7
	b.eq	.Lret0_4

.Ltiny8proc_4:
	ldrb	data1w, [src1], #1
	ldrb	data2w, [src2], #1
	subs	limit, limit, #1

	ccmp	data1w, data2w, #0, ne  /* NZCV = 0b0000. */
	b.eq	.Ltiny8proc_4
	sub	result, data1, data2
	ret
.Lret0_4:
	mov	result, #0
	ret
ENDPROC(memcmp_tlx)

ENTRY(clear_page_tlx)
	mrs	x1, dczid_el0
	and	w1, w1, #0xf
	mov	x2, #4
	lsl	x1, x2, x1

1:	dc	zva, x0
	add	x0, x0, x1
	tst	x0, #(PAGE_SIZE - 1)
	b.ne	1b
	ret
ENDPROC(clear_page_tlx)

ENTRY(__inval_cache_range_tlx)
	/* FALLTHROUGH */

/*
 *	__dma_inv_range(start, end)
 *	- start   - virtual start address of region
 *	- end     - virtual end address of region
 */

 .macro	dcache_line_size, reg, tmp
 mrs	\tmp, ctr_el0			// read CTR
 ubfm	\tmp, \tmp, #16, #19		// cache line size encoding
 mov	\reg, #4			// bytes per word
 lsl	\reg, \reg, \tmp		// actual cache line size
 .endm

__dma_inv_range:
	dcache_line_size x2, x3
	sub	x3, x2, #1
	tst	x1, x3				// end cache line aligned?
	bic	x1, x1, x3
	b.eq	1f
	dc	civac, x1			// clean & invalidate D / U line
1:	tst	x0, x3				// start cache line aligned?
	bic	x0, x0, x3
	b.eq	2f
	dc	civac, x0			// clean & invalidate D / U line
	b	3f
2:	dc	ivac, x0			// invalidate D / U line
3:	add	x0, x0, x2
	cmp	x0, x1
	b.lo	2b
	dsb	sy
	ret
ENDPROC(__inval_cache_range_tlx)

#define MAIR(attr, mt)	((attr) << ((mt) * 8))
#define MT_DEVICE_nGnRnE        0
#define MT_DEVICE_nGnRE         1
#define MT_DEVICE_GRE           2
#define MT_NORMAL_NC            3
#define MT_NORMAL               4

#define TCR_SMP_FLAGS	0
#define TCR_CACHE_FLAGS	TCR_IRGN_WBWA | TCR_ORGN_WBWA
#define TCR_TG_FLAGS	TCR_TG0_4K | TCR_TG1_4K
#define TCR_ASID16		(UL(1) << 36)
#define TCR_TBI0		(UL(1) << 37)
#define TCR_TG0_4K		(UL(0) << 14)
#define TCR_TG1_4K		(UL(2) << 30)
#define TCR_ORGN_WBWA		((UL(1) << 10) | (UL(1) << 26))
#define TCR_IRGN_WBWA		((UL(1) << 8) | (UL(1) << 24))
#define TCR_CACHE_FLAGS	TCR_IRGN_WBWA | TCR_ORGN_WBWA

#define VA_BITS                 (39)

#define TCR_TxSZ(x)		(((UL(64) - (x)) << 16) | ((UL(64) - (x)) << 0))

#define _AC(X,Y)        X
#define UL(x) _AC(x, UL)

ENTRY(__cpu_setup_tlx)
	ic	iallu				// I+BTB cache invalidate
	tlbi	vmalle1is			// invalidate I + D TLBs
	dsb	ish

	mov	x0, #3 << 20
	msr	cpacr_el1, x0			// Enable FP/ASIMD
	msr	mdscr_el1, xzr			// Reset mdscr_el1
	/*
	 * Memory region attributes for LPAE:
	 *
	 *   n = AttrIndx[2:0]
	 *			n	MAIR
	 *   DEVICE_nGnRnE	000	00000000
	 *   DEVICE_nGnRE	001	00000100
	 *   DEVICE_GRE		010	00001100
	 *   NORMAL_NC		011	01000100
	 *   NORMAL		100	11111111
	 */
	ldr	x5, =MAIR(0x00, MT_DEVICE_nGnRnE) | \
		     MAIR(0x04, MT_DEVICE_nGnRE) | \
		     MAIR(0x0c, MT_DEVICE_GRE) | \
		     MAIR(0x44, MT_NORMAL_NC) | \
		     MAIR(0xff, MT_NORMAL)
	msr	mair_el1, x5
	/*
	 * Prepare SCTLR
	 */
	adr	x5, crval
	ldp	w5, w6, [x5]
	mrs	x0, sctlr_el1
	bic	x0, x0, x5			// clear bits
	orr	x0, x0, x6			// set bits
	/*
	 * Set/prepare TCR and TTBR. We use 512GB (39-bit) address range for
	 * both user and kernel.
	 */
	ldr	x10, =TCR_TxSZ(VA_BITS) | TCR_CACHE_FLAGS | TCR_SMP_FLAGS | \
			TCR_TG_FLAGS | TCR_ASID16 | TCR_TBI0
	/*
	 * Read the PARange bits from ID_AA64MMFR0_EL1 and set the IPS bits in
	 * TCR_EL1.
	 */
	mrs	x9, ID_AA64MMFR0_EL1
	bfi	x10, x9, #32, #3
	msr	tcr_el1, x10
	ret					// return to head.S
ENDPROC(__cpu_setup_tlx)

.type	crval, #object
crval:
.word	0x000802e2			// clear
.word	0x0405d11d			// set
