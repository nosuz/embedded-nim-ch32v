# define STORE    sw
# define LOAD     lw
# define LOG_REGBYTES 2
#define REGBYTES (1 << LOG_REGBYTES)

/* default entry point */

.section .init, "ax"
.global _start

_start:
    # CH32V103 starts from 0x0000_0004 but CH32V203 starts from 0x0000_0000.
    nop
    nop

    # set global pointer
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    # set stack pointer
    la sp, _stack_start

copy_data_section:
    # copy data section to RAM
    la a0, _sdata_lma
    la a1, _sdata
    la a2, _edata_lma
    beq a1, a2, copy_data_done
copy_data_loop:
    lb t0, 0(a0)
    sb t0, 0(a1)
    addi a0, a0, 1
    addi a1, a1, 1
    bltu a1, a2, copy_data_loop
copy_data_done:

clear_bss_section:
    # clear bss section
    li t0, 0
    la t1, _sbss
    la t2, _ebss
    beq t1, t2, clear_bss_done
clear_bss_loop:
    sb t0, 0(t1)
    addi t1, t1, 1
    bne t1, t2, clear_bss_loop
clear_bss_done:

    # Set frame pointer
    add s0, sp, zero

    # call nim routine
    jal NimMain

exited_loop:
    j exited_loop
