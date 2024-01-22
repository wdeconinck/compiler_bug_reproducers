# Compiler Bug Reproducers

This code is extracted from https://github.com/ecmwf/fckit to illustrate compiler bugs encountered with Intel-LLVM 2023.2
and cce-16

The code is altered compared to the original in order to create a minimal reproducer

## Problem with cce-16 on (tested on LUMI)

An allocatable array of derived type `fckit_configuration` is declared
The type `fckit_configuration` contains automatic finalization.
```f90
type(fckit_configuration), allocatable :: config_array(:)
```
The array config_array is only allocated conditionally.

In case it is not allocated, automatic
finalization for the array is attempted anyway in an infinite loop or a SEGFAULT.

Workaround involves assigning the `config_array`, or allocating it with zero size as in
```f90
allocate(config_array(0))
```

### Instructions to reproduce error:

Environment on LUMI:

    source env/lumi/cce-16.sh

Compile:

    rm -rf build
    cmake -S . -B build
    cmake --build build

Run failing test:

    build/bin/reproducer_unallocated

Run working test with `allocate(config_array(0))` workaround:

    build/bin/reproducer_allocate_zero

Run working test with assigned `config_array`:

    build/bin/reproducer_assign





## Problem with Intel 2023.2 (tested on ECMWF's Atos HPC)

An allocatable array of derived type `fckit_configuration` is assigned 3 values
The type `fckit_configuration` contains automatic finalization.
```f90
type(fckit_configuration), allocatable :: config_array(:)
```
Even though the `fckit_configuration` has `impure elemental` attributes to the `final` subroutine,
and gets applied to all elements of `config_array`.
The type `fckit_configuration` however extends `fckit_shared_object` type, which also has a `impure elemental final` subroutine.
The problem now is that the automatic finalisation from the base type is only applied to the first element of `config_array`.


### Instructions to reproduce error:

Environment on ECMWF's Atos HPC:

    source env/ecmwf-hpc2020/intel-llvm-2023.2.sh

Compile:

    rm -rf build
    cmake -S . -B build
    cmake --build build

Run failing test:

    build/bin/reproducer_assign

# Comparisons

### Platform/Compilers known to work:

- ecmwf-hpc2020 | gnu 8.5
- ecmwf-hpc2020 | gnu 13.1 (only compiler that requires assignment operator in `type(fckit_shared_object)`)
- ecmwf-hpc2020 | nvidia 22.11

### Platform/Compilers known to fail:

- LUMI | cce 16
- ecmwf-hpc2020 | intel 2023.2
- ecmwf-hpc2020 | intel-llvm 2023.2
