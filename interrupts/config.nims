when defined(useVTF):
    echo "Use VTF for interrupt handling"
    switch("gcc.options.linker", "-T src/linker_vtf.ld --gc-sections $(riscv32-unknown-elf-gcc -print-libgcc-file-name)")
    switch("clang.options.linker", "-T src/linker_vtf.ld -target riscv32 -march=rv32imac -mabi=ilp32 --sysroot=$(riscv32-unknown-elf-gcc -print-sysroot) -L$(dirname $(riscv32-unknown-elf-gcc -print-libgcc-file-name)) -flto")
else:
    echo "Use unified interrupt"
    switch("gcc.options.linker", "-T src/linker_unified.ld --gc-sections $(riscv32-unknown-elf-gcc -print-libgcc-file-name)")
    switch("clang.options.linker", "-T src/linker_unified.ld -target riscv32 -march=rv32imac -mabi=ilp32 --sysroot=$(riscv32-unknown-elf-gcc -print-sysroot) -L$(dirname $(riscv32-unknown-elf-gcc -print-libgcc-file-name)) -flto")
