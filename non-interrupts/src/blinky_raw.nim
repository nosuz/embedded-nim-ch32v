{.compile: "start.s"}

import std/volatile
# import std/bitops

# メモリマップドIOアドレスを定義
# https://www.reddit.com/r/nim/comments/t7wnrr/specify_address_of_a_variable/
const
    RCC_APB2PCENR = cast[ptr uint32](0x40021018'u32)
    GPIOA_CFGLR = cast[ptr uint32](0x40010800'u32)
    # GPIOA_CFGHR = cast[ptr uint32](0x40010804'u32)
    # GPIOA_INDR = cast[ptr uint32](0x40010808'u32)
    GPIOA_OUTDR = cast[ptr uint32](0x4001080C'u32)
    # GPIOA_BSHR = cast[ptr uint32](0x40010810'u32)
    # GPIOA_BCR = cast[ptr uint32](0x40010814'u32)

proc port_init() =
    # Enable PA clock
    # var apb2pcenr = volatileLoad(RCC_APB2PCENR)
    # apb2pcenr.setBit(1 shl 2)
    # RCC_APB2PCENR[] = apb2pcenr
    RCC_APB2PCENR[] = volatileLoad(RCC_APB2PCENR) or (1 shl 2)

    var gpioa_cfg = volatileLoad(GPIOA_CFGLR)
    gpioa_cfg = gpioa_cfg and not (0b1111'u32 shl 20)
    GPIOA_CFGLR[] = gpioa_cfg or (0b0001'u32 shl 20)

proc port_set(s: bool) =
    GPIOA_OUTDR[] = uint32(s) shl 5
    # volatileStore(GPIOA_OUTDR, uint32(s) shl 5)

proc delay() =
    const delay = 1_000_000
    for _ in 0..delay:
        asm """
        nop
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
        port_set(true)
        delay()
        port_set(false)
        delay()
