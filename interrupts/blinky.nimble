import std/strformat

# Package

version       = "0.1.0"
author        = "Norio Suzuki"
description   = "embedded nim interrupt example"
license       = "MIT"
srcDir        = "src"
bin           = @["blinky_int"]
binDir        = "firmware/"

# Dependencies

requires "nim >= 2.2.4"

after build:
    let binary = bin[0]
    exec fmt"riscv32-unknown-elf-objcopy -O binary {binDir}{binary} {binDir}{binary}.bin"
    exec fmt"riscv32-unknown-elf-objdump -d {binDir}{binary} > {binDir}{binary}.s"

task flash, "Flash firmware.":
    let binary = bin[0]
    exec fmt"wch-isp -r flash {binDir}{binary}.bin"

task svd, "Convert SVD file":
    exec "cd src/svd && svd2nim ch32v20x.svd"
