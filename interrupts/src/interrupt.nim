type
    Interrupt* = object
        id*: uint32
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
