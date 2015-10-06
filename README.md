# one file linux

Simple OS for ARM64 (aarch64) architecture.

*  Follow standard guide to prepare build and test environment (for ordinary ARM64 Kernel)
*  Run ./build_it.sh
*  Run qemu

`qemu-system-aarch64  -machine virt -cpu cortex-a57 -machine type=virt -nographic -smp 1 -m 512 -kernel ./arch/arm64/boot/Image --append "console=ttyAMA0"`

* Only couple syscall now working: for testing enter
`ls`
* Close qemu by CTRL-A and X after that
