#define LOG_REGBYTES 2
#define REGBYTES (1 << LOG_REGBYTES)

.section .init, "ax"
/* entry point */
.global _start

_start:
    // CH32V103 starts from 0x0000_0004 but CH32V203 starts from 0x0000_0000.
    nop
    nop

    // set global pointer
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    // set stack pointer
    la sp, _stack_start

    // set interrupts trap vec.
    la      t0, interrupt_handler
    csrw    mtvec, t0

copy_data_section:
    // copy data section to RAM
    la a0, _sdata_lma
    la a1, _sdata
    la a2, _edata_lma
    beq a1, a2, copy_data_done
copy_data_loop:
    lw t0, 0(a0)
    sw t0, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    bltu a1, a2, copy_data_loop
copy_data_done:

clear_bss_section:
    // clear bss section
    li t0, 0
    la t1, _sbss
    la t2, _ebss
    beq t1, t2, clear_bss_done
clear_bss_loop:
    sw t0, 0(t1)
    addi t1, t1, 4
    bne t1, t2, clear_bss_loop
clear_bss_done:

    // Set frame pointer
    add s0, sp, zero

    // call nim routine
    jal NimMain

exited_loop:
    j exited_loop

.weak dispatchInterrupt
.global unhandled_handler
.type unhandled_handler, @function

dispatchInterrupt:
unhandled_handler:
    ret

.section .handlers, "ax"
interrupt_handler:
    addi sp, sp, -16*REGBYTES

    sw ra, 0*REGBYTES(sp)
    sw t0, 1*REGBYTES(sp)
    sw t1, 2*REGBYTES(sp)
    sw t2, 3*REGBYTES(sp)
    sw t3, 4*REGBYTES(sp)
    sw t4, 5*REGBYTES(sp)
    sw t5, 6*REGBYTES(sp)
    sw t6, 7*REGBYTES(sp)
    sw a0, 8*REGBYTES(sp)
    sw a1, 9*REGBYTES(sp)
    sw a2, 10*REGBYTES(sp)
    sw a3, 11*REGBYTES(sp)
    sw a4, 12*REGBYTES(sp)
    sw a5, 13*REGBYTES(sp)
    sw a6, 14*REGBYTES(sp)
    sw a7, 15*REGBYTES(sp)

    // set sp vale to a0 or the 1st. arg.
    // add a0, sp, zero
    // interrupts_handler(sp, mcause, mepc);
    // csrr a1, mcause
    // csrr a2, mepc
    // interrupts_handler(mcause: u32);
    csrr a0, mcause
    jal ra, dispatchInterrupt

    lw ra, 0*REGBYTES(sp)
    lw t0, 1*REGBYTES(sp)
    lw t1, 2*REGBYTES(sp)
    lw t2, 3*REGBYTES(sp)
    lw t3, 4*REGBYTES(sp)
    lw t4, 5*REGBYTES(sp)
    lw t5, 6*REGBYTES(sp)
    lw t6, 7*REGBYTES(sp)
    lw a0, 8*REGBYTES(sp)
    lw a1, 9*REGBYTES(sp)
    lw a2, 10*REGBYTES(sp)
    lw a3, 11*REGBYTES(sp)
    lw a4, 12*REGBYTES(sp)
    lw a5, 13*REGBYTES(sp)
    lw a6, 14*REGBYTES(sp)
    lw a7, 15*REGBYTES(sp)

    addi sp, sp, 16*REGBYTES
    mret
