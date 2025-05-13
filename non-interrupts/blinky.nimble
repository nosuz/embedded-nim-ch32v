import std/strformat

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
    for binary in bin:
        exec fmt"riscv32-unknown-elf-objcopy -O binary {binDir}{binary} {binDir}{binary}.bin"
        exec fmt"riscv32-unknown-elf-objdump -d {binDir}{binary} > {binDir}{binary}.s"

task flash, "Flash firmware. Usage: nimble flash [svd|raw]":
    let binary = case commandLineParams[^1]
    of "raw": "blinky_raw"
    of "svd": "blinky_svd"
    else: "blinky_svd"

    # echo fmt"writing {binary}"
    echo "writing $1" % [binary]
    exec fmt"wch-isp -r flash {binDir}{binary}.bin"

task svd, "Convert SVD file":
    exec "cd src/svd && svd2nim ch32v20x.svd"
