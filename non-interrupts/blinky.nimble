# Package

version       = "0.1.0"
author        = "Norio Suzuki"
description   = "embedded nim examples"
license       = "MIT"
srcDir        = "src"
bin           = @["blinky_raw"]
binDir        = "firmware/"

# Dependencies

requires "nim >= 2.2.4"

after build:
    exec "riscv32-unknown-elf-objcopy -O binary firmware/blinky_raw firmware/blinky_raw.bin"
    exec "riscv32-unknown-elf-objdump -d firmware/blinky_raw > firmware/blinky_raw.s"

task flash, "Flash firmware":
    case commandLineParams[^1]
    of "raw":
        exec "wch-isp -r flash firmware/blinky_raw.bin"
    else:
        exec "wch-isp -r flash firmware/blinky_raw.bin"
