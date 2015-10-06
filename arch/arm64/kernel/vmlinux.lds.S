/*
 * ld script to make ARM Linux kernel
 * taken from the i386 version by Russell King
 * Written by Martin Mares <mj@atrey.karlin.mff.cuni.cz>
 */



#define CLK_OF_TABLES()		OF_TABLE(CONFIG_COMMON_CLK, clk)

#define NOSAVE_DATA							\
	. = ALIGN(PAGE_SIZE);						\
	VMLINUX_SYMBOL(__nosave_begin) = .;				\
	*(.data..nosave)						\
	. = ALIGN(PAGE_SIZE);						\
	VMLINUX_SYMBOL(__nosave_end) = .;

#define INIT_TASK_DATA(align)						\
	. = ALIGN(align);						\
	*(.data..init_task)

#ifndef BSS_FIRST_SECTIONS
#define BSS_FIRST_SECTIONS
#endif


#define BSS(bss_align)							\
	. = ALIGN(bss_align);						\
	.bss : AT(ADDR(.bss) - LOAD_OFFSET) {				\
		BSS_FIRST_SECTIONS					\
		*(.bss..page_aligned)					\
		*(.dynbss)						\
		*(.bss)							\
		*(COMMON)						\
	}

#define SBSS(sbss_align)						\
	. = ALIGN(sbss_align);						\
	.sbss : AT(ADDR(.sbss) - LOAD_OFFSET) {				\
		*(.sbss)						\
		*(.scommon)						\
	}


#define BSS_SECTION(sbss_align, bss_align, stop_align)			\
	. = ALIGN(sbss_align);						\
	VMLINUX_SYMBOL(__bss_start) = .;				\
	SBSS(sbss_align)						\
	BSS(bss_align)							\
	. = ALIGN(stop_align);						\
	VMLINUX_SYMBOL(__bss_stop) = .;


#define PAGE_ALIGNED_DATA(page_align)					\
	. = ALIGN(page_align);						\
	*(.data..page_aligned)

#define CACHELINE_ALIGNED_DATA(align)					\
	. = ALIGN(align);						\
	*(.data..cacheline_aligned)


#define DATA_DATA							\
	*(.data)							\
	*(.ref.data)							\
	*(.data..shared_aligned) /* percpu related */			\
	MEM_KEEP(init.data)						\
	MEM_KEEP(exit.data)						\
	*(.data.unlikely)						\
	STRUCT_ALIGN();							\
	*(__tracepoints)						\
	/* implement dynamic printk debug */				\
	. = ALIGN(8);                                                   \
	VMLINUX_SYMBOL(__start___jump_table) = .;                       \
	*(__jump_table)                                                 \
	VMLINUX_SYMBOL(__stop___jump_table) = .;                        \
	. = ALIGN(8);							\
	VMLINUX_SYMBOL(__start___verbose) = .;                          \
	*(__verbose)                                                    \
	VMLINUX_SYMBOL(__stop___verbose) = .;				\


#define RW_DATA_SECTION(cacheline, pagealigned, inittask)		\
	. = ALIGN(PAGE_SIZE);						\
	.data : AT(ADDR(.data) - LOAD_OFFSET) {				\
		INIT_TASK_DATA(inittask)				\
		NOSAVE_DATA						\
		PAGE_ALIGNED_DATA(pagealigned)				\
		CACHELINE_ALIGNED_DATA(cacheline)			\
		DATA_DATA						\
	}

#define PERCPU_INPUT(cacheline)						\
	VMLINUX_SYMBOL(__per_cpu_start) = .;				\
	*(.data..percpu..first)						\
	. = ALIGN(PAGE_SIZE);						\
	*(.data..percpu..page_aligned)					\
	. = ALIGN(cacheline);						\
	*(.data..percpu..read_mostly)					\
	. = ALIGN(cacheline);						\
	*(.data..percpu)						\
	*(.data..percpu..shared_aligned)				\
	VMLINUX_SYMBOL(__per_cpu_end) = .;

#define PERCPU_SECTION(cacheline)					\
	. = ALIGN(PAGE_SIZE);						\
	.data..percpu	: AT(ADDR(.data..percpu) - LOAD_OFFSET) {	\
		VMLINUX_SYMBOL(__per_cpu_load) = .;			\
		PERCPU_INPUT(cacheline)					\
	}

#ifdef CONFIG_BLK_DEV_INITRD
#define INIT_RAM_FS							\
	. = ALIGN(4);							\
	VMLINUX_SYMBOL(__initramfs_start) = .;				\
	*(.init.ramfs)							\
	. = ALIGN(8);							\
	*(.init.ramfs.info)
#else
#define INIT_RAM_FS
#endif

#define STRUCT_ALIGNMENT 32
#define STRUCT_ALIGN() . = ALIGN(STRUCT_ALIGNMENT)

#define KERNEL_DTB()							\
	STRUCT_ALIGN();							\
	VMLINUX_SYMBOL(__dtb_start) = .;				\
	*(.dtb.init.rodata)						\
	VMLINUX_SYMBOL(__dtb_end) = .;

#define ___OF_TABLE(cfg, name)	_OF_TABLE_##cfg(name)
#define __OF_TABLE(cfg, name)	___OF_TABLE(cfg, name)
#define OF_TABLE(cfg, name)	__OF_TABLE(config_enabled(cfg), name)
#define _OF_TABLE_0(name)
#define _OF_TABLE_1(name)						\
	. = ALIGN(8);							\
	VMLINUX_SYMBOL(__##name##_of_table) = .;			\
	*(__##name##_of_table)						\
	*(__##name##_of_table_end)


#define CLKSRC_OF_TABLES()	OF_TABLE(CONFIG_CLKSRC_OF, clksrc)
#define IRQCHIP_OF_MATCH_TABLE() OF_TABLE(CONFIG_IRQCHIP, irqchip)

#define INIT_DATA							\
	CLK_OF_TABLES()							\
	KERNEL_DTB()							\
	IRQCHIP_OF_MATCH_TABLE()


#define ALIGN_FUNCTION()  . = ALIGN(8)
#define MEM_KEEP(sec)
#define MEM_DISCARD(sec)

#ifndef LOAD_OFFSET
#define LOAD_OFFSET 0
#endif

#ifdef CONFIG_HAVE_UNDERSCORE_SYMBOL_PREFIX
#define __VMLINUX_SYMBOL(x) _##x
#define __VMLINUX_SYMBOL_STR(x) "_" #x
#else
#define __VMLINUX_SYMBOL(x) x
#define __VMLINUX_SYMBOL_STR(x) #x
#endif

/* Indirect, so macros are expanded before pasting. */
#define VMLINUX_SYMBOL(x) __VMLINUX_SYMBOL(x)
#define VMLINUX_SYMBOL_STR(x) __VMLINUX_SYMBOL_STR(x)

#define INIT_TEXT							\
	*(.init.text)							\
	MEM_DISCARD(init.text)

#define INIT_TEXT_SECTION(inittext_align)				\
	. = ALIGN(inittext_align);					\
	.init.text : AT(ADDR(.init.text) - LOAD_OFFSET) {		\
		VMLINUX_SYMBOL(_sinittext) = .;				\
		INIT_TEXT						\
		VMLINUX_SYMBOL(_einittext) = .;				\
	}


#define HEAD_TEXT  *(.head.text)
#define TEXT_TEXT							\
		ALIGN_FUNCTION();					\
		*(.text.hot)						\
		*(.text)						\
		*(.ref.text)						\
	MEM_KEEP(init.text)						\
	MEM_KEEP(exit.text)						\
		*(.text.unlikely)


#define THREAD_SIZE             16384
#define _AC(X,Y)	X
#define UL(x) _AC(x, UL)
#ifdef CONFIG_ARM64_64K_PAGES
#define VA_BITS			(42)
#else
#define VA_BITS			(39)
#endif
#define PAGE_OFFSET		(UL(0xffffffffffffffff) << (VA_BITS - 1))
#define TASK_SIZE_64		(UL(1) << VA_BITS)
#define TASK_SIZE		TASK_SIZE_64

#ifdef CONFIG_ARM64_64K_PAGES
#define PAGE_SHIFT              16
#else
#define PAGE_SHIFT              12
#endif
#define PAGE_SIZE               (_AC(1,UL) << PAGE_SHIFT)



SECTIONS
{
	/*
	 * XXX: The linker does not define how output sections are
	 * assigned to input sections when there are multiple statements
	 * matching the same input section name.  There is no documented
	 * order of matching.
	 */
	/DISCARD/ : {
		*(.discard)
		*(.discard.*)
	}

	. = PAGE_OFFSET + TEXT_OFFSET;

	.head.text : {
		_text = .;
		HEAD_TEXT
	}
	.text : {			/* Real text segment		*/
		_stext = .;		/* Text and read-only data	*/
			__exception_text_start = .;
			*(.exception.text)
			__exception_text_end = .;
			TEXT_TEXT
			*(.fixup)
			*(.gnu.warning)
		. = ALIGN(16);
		*(.got)			/* Global offset table		*/
	}

	_etext = .;			/* End of text and rodata section */

	. = ALIGN(PAGE_SIZE);
	__init_begin = .;

	INIT_TEXT_SECTION(8)
	.exit.text : {
	}
	. = ALIGN(16);
	.init.data : {
		INIT_DATA
		INIT_RAM_FS
	}
	.exit.data : {
	}

	PERCPU_SECTION(64)

	__init_end = .;

	. = ALIGN(PAGE_SIZE);
	_data = .;
	_sdata = .;
	RW_DATA_SECTION(64, PAGE_SIZE, THREAD_SIZE)
	_edata = .;

	BSS_SECTION(0, 0, 0)
	_end = .;
}
