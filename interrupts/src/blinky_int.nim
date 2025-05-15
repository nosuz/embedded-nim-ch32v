{.compile: "start.S"}

# import svd file
import svd/ch32v20xx
# import interrupt related type and functions
import ./interrupt

const CpuFreq = 8_000_000

proc port_init() =
    # Enable PA clock
    RCC.APB2PCENR.modifyIt:
        it.IOPAEN = true

    GPIOA.CFGLR.modifyIt:
        it.MODE5 = 0b01
        it.CNF5 = 0b00

proc setup_timer() =
    RCC.APB2PCENR.modifyIt:
        it.TIM1EN = true

    # count update every 0.1ms.
    let prescale = uint32(CpuFreq / 1_000_000 * 100 - 1)
    TIM1.PSC.write(PSC = prescale)

    # 0.1ms * 2500 = 250ms or blink every 0.5 sec.
    const count = 2500
    TIM1.CNT.write(CNT = count)
    TIM1.ATRLR.write(ATRLR = count)
    TIM1.CTLR1.modifyIt:
        it.ARPE = true
        it.CEN = true

    # clear interupt requist by the above counter update
    TIM1.INTFR.modifyIt:
        it.UIF = false
    PFIC.IPRR2.write(1 shl (int(irqTIM1_UP) - 32)) # TIM1_UP = 41

    # enable interrupt on Update.
    TIM1.DMAINTENR.modifyIt:
        it.UIE = true

    # enable interrupts
    let ienr = uint32(1 shl (int(irqTIM1_UP) - 32))
    PFIC.IENR2.write(ienr) # write-only

proc timer_handler() =
    let pa5 = GPIOA.OUTDR.read().ODR5
    GPIOA.OUTDR.modifyIt:
        # it.ODR5 = if pa5: true else: false
        it.ODR5 = not pa5
    # clear interrupt
    TIM1.INTFR.modifyIt:
        it.UIF = false

const interruptHandlers = [
    Interrupt(id: uint32(irqTIM1_UP), handler: timer_handler),
]

# this function name is fixed.
proc dispatchInterrupt(mcause: uint32) {.exportc.} =
    # MSB of mcause is always 1 on interrupt
    # expcted "andi a0, a0, 0xff". this code is same as "zext.b	a0,a0"
    let src_id = mcause and 0xff
    for handler in interruptHandlers:
        if src_id == handler.id:
            handler.handler()
            return
    # fallback
    # but this will not work because the flag is not cleared
    unhandled_handler()

proc interrupt_handler(): void {.importc.}

block main:
    port_init()
    setup_timer()

    # VTF can handle upto 4 interrupts.
    PFIC.VTFIDR.write(VTFID0 = uint8(irqTIM1_UP))
    let handlerAddr = cast[uint32](cast[pointer](interrupt_handler))
    PFIC.VTFADDRR0.write(ADDR0 = handlerAddr, VTF0EN = true)

    enable_interrupt()

    while true:
        # this nop will removed by optimization
        asm """
            nop
        """
