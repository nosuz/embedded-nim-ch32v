# Package

version       = "0.1.0"
author        = "Norio Suzuki"
description   = "embedded nim examples"
license       = "MIT"
srcDir        = "src"
bin           = @["blinky_raw", "blinky_svd"]
binDir        = "firmware/"

# Dependencies

requires "nim >= 2.2.4"

after build:
    exec "riscv32-unknown-elf-objcopy -O binary firmware/blinky_raw firmware/blinky_raw.bin"
    exec "riscv32-unknown-elf-objdump -d firmware/blinky_raw > firmware/blinky_raw.s"

    exec "riscv32-unknown-elf-objcopy -O binary firmware/blinky_svd firmware/blinky_svd.bin"
    exec "riscv32-unknown-elf-objdump -d firmware/blinky_svd > firmware/blinky_svd.s"

task flash, "Flash firmware":
    case commandLineParams[^1]
    of "raw":
        exec "wch-isp -r flash firmware/blinky_raw.bin"
    of "svd":
        exec "wch-isp -r flash firmware/blinky_svd.bin"
    else:
        exec "wch-isp -r flash firmware/blinky_svd.bin"

task svd, "Convert SVD file":
    exec "cd src/svd && svd2nim ch32v20x.svd"