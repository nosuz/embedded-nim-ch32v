import ../../svd/ch32v20xx

type
    Interrupt* = object
        id*: IRQn
        # handler*: string
        handler*: proc()

proc enable_interrupt*() =
    asm """
        csrwi mstatus, (1 << 3)
    """

proc disable_interrupt*() =
    asm """
        csrr t0, mstatus
        andi t0, t0, ~(1 << 3)
        csrw mstatus, t0
    """

proc unhandled_handler*() {.importc: "unhandled_handler".}

proc interrupt_handler(): void {.importc.}

when defined(useVTF):
    {.passc: "-DUSE_VTF".}
    proc setVTF*(handlers: seq) =
        let handlerAddr = cast[uint32](cast[pointer](interrupt_handler))

        # VTF can handle upto 4 interrupts.
        for index, handler in handlers:
            case index
            of 0:
                PFIC.VTFIDR.write(VTFID0 = uint8(handler.id))
                PFIC.VTFADDRR0.write(ADDR0 = handlerAddr, VTF0EN = true)
            of 1:
                PFIC.VTFIDR.write(VTFID1 = uint8(handler.id))
                PFIC.VTFADDRR1.write(ADDR1 = handlerAddr, VTF1EN = true)
            of 2:
                PFIC.VTFIDR.write(VTFID2 = uint8(handler.id))
                PFIC.VTFADDRR2.write(ADDR2 = handlerAddr, VTF2EN = true)
            of 3:
                PFIC.VTFIDR.write(VTFID3 = uint8(handler.id))
                PFIC.VTFADDRR3.write(ADDR3 = handlerAddr, VTF3EN = true)
            else:
                discard
else:
    proc setVTF*(handlers: seq) =
        static:
            echo "⚠️ useVTF is not defined in nim.cfg"
