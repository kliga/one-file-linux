rm arch/arm64/kernel/vmlinux.lds
rm arch/arm64/kernel/.vmlinux.lds.d
rm arch/arm64/kernel/head.o
rm arch/arm64/kernel/.head.o.d
rm arch/arm64/kernel/entry.o
rm arch/arm64/kernel/.entry.o.d
rm arch/arm64/kernel/vdso/sigreturn.o
rm arch/arm64/kernel/vdso/.sigreturn.o.d
rm arch/arm64/kernel/vdso/vdso.so
rm arch/arm64/kernel/vdso/vdso.so.dbg
rm arch/arm64/init/main.o
rm arch/arm64/init/.main.o.d
rm arch/arm64/boot/Image
rm vmlinux


aarch64-linux-gnu-gcc -Wp,-MD,arch/arm64/kernel/vdso/.sigreturn.o.d  -nostdinc -isystem /usr/lib/gcc-cross/aarch64-linux-gnu/4.8/include -D__KERNEL__ -mlittle-endian  -D__ASSEMBLY__ -Wa,-gdwarf-2 -c -o arch/arm64/kernel/vdso/sigreturn.o arch/arm64/kernel/vdso/sigreturn.S


aarch64-linux-gnu-gcc -Wp,-MD,arch/arm64/kernel/vdso/.vdso.so.dbg.d  -nostdinc -isystem /usr/lib/gcc-cross/aarch64-linux-gnu/4.8/include -D__KERNEL__ -mlittle-endian -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -mgeneral-regs-only -fno-delete-null-pointer-checks -O2 -Wframe-larger-than=2048 -fno-stack-protector -Wno-unused-but-set-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-var-tracking-assignments -g -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes -shared -fno-common -fno-builtin -nostdlib -Wl,-soname=linux-vdso.so.1 -Wl,--hash-style=sysv -Wl,-n -Wl,-T arch/arm64/kernel/vdso/vdso.lds arch/arm64/kernel/vdso/sigreturn.o -o arch/arm64/kernel/vdso/vdso.so.dbg


aarch64-linux-gnu-objcopy -S  arch/arm64/kernel/vdso/vdso.so.dbg arch/arm64/kernel/vdso/vdso.so

aarch64-linux-gnu-gcc -Wp,-MD,arch/arm64/kernel/.entry.o.d  -nostdinc -isystem /usr/lib/gcc-cross/aarch64-linux-gnu/4.8/include  -Iinclude -include ./include/linux/kconfig.h -D__KERNEL__ -mlittle-endian  -D__ASSEMBLY__ -Wa,-gdwarf-2         -c -o arch/arm64/kernel/entry.o arch/arm64/kernel/entry.S

aarch64-linux-gnu-gcc -Wp,-MD,arch/arm64/kernel/.head.o.d  -nostdinc -isystem /usr/lib/gcc-cross/aarch64-linux-gnu/4.8/include -Iinclude -include ./include/linux/kconfig.h -D__KERNEL__ -mlittle-endian  -D__ASSEMBLY__ -Wa,-gdwarf-2      -DTEXT_OFFSET=0x00080000   -c -o arch/arm64/kernel/head.o arch/arm64/kernel/head.S


aarch64-linux-gnu-gcc -E -Wp,-MD,arch/arm64/kernel/.vmlinux.lds.d  -nostdinc -isystem /usr/lib/gcc-cross/aarch64-linux-gnu/4.8/include -Iinclude -include ./include/linux/kconfig.h -D__KERNEL__ -mlittle-endian    -DTEXT_OFFSET=0x00080000 -P -C -Uarm64 -D__ASSEMBLY__ -DLINKER_SCRIPT -o arch/arm64/kernel/vmlinux.lds arch/arm64/kernel/vmlinux.lds.S

aarch64-linux-gnu-gcc -Wp,-MD,init/.main.o.d  -nostdinc -isystem /usr/lib/gcc-cross/aarch64-linux-gnu/4.8/include -include ./include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -mgeneral-regs-only -fno-delete-null-pointer-checks -O2 -Wframe-larger-than=2048 -fno-stack-protector -Wno-unused-but-set-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-var-tracking-assignments -g -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes  -c -o init/main.o init/main.c


aarch64-linux-gnu-ld -EL  -p --no-undefined -X --build-id -o vmlinux \
		-T ./arch/arm64/kernel/vmlinux.lds arch/arm64/kernel/head.o  init/main.o \
	         --start-group arch/arm64/kernel/entry.o /usr/lib/gcc-cross/aarch64-linux-gnu/4.8/libgcc.a /usr/lib/gcc-cross/aarch64-linux-gnu/4.8/libgcc.a --end-group


aarch64-linux-gnu-objcopy -O binary -R .note -R .note.gnu.build-id -R .comment -S  vmlinux arch/arm64/boot/Image



