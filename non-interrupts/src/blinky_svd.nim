{.compile: "start.S"}

# import svd file
import svd/ch32v20xx

proc port_init() =
    # Enable PA clock
    RCC.APB2PCENR.modifyIt:
        it.IOPAEN = true

    GPIOA.CFGLR.modifyIt:
        it.MODE5 = 0b01
        it.CNF5 = 0b00

# proc port_set(s: bool) =
#     GPIOA.OUTDR.modifyIt:
#         it.ODR5 = s

proc port_toggle() =
    let pa5 = GPIOA.OUTDR.read().ODR5
    GPIOA.OUTDR.modifyIt:
        # it.ODR5 = if pa5: true else: false
        it.ODR5 = not pa5

proc delay() =
    const delay = 1_000_000
    for _ in 0..delay:
        # asm """
        #     nop
        # """
        asm """
            "" : : : "memory"
        """

# proc main() {.noreturn.} =
#     port_init()

#     while true:
#         port_set(true)
#         delay()
#         port_set(false)
#         delay()

# main()

block main:
    port_init()

    while true:
        port_toggle()
        delay()
