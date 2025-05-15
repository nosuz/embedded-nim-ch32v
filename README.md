# Embedded nim examples

This example have two examples.

1. basic examples
2. interrupt example

## Build and flash firmware

Thes examples work only on CH32V203. But it should works on both CH32V003 or CH32V303 with some modefications.

```bash
# build
nimble build

# write binary onto the flash memory
nimble flash
```

### Required tools

#### GCC or Clang

#### flash tool

For CH32V203 and CH32V303, wch-isp or wchisp is requied
For CH32V003, wlink is required

## SVD file

[svd2nim](https://github.com/EmbeddedNim/svd2nim)
