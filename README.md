# Compiler Bug Reproducers

This code is extracted from https://github.com/ecmwf/fckit to illustrate compiler bugs encountered with cce/15 .
The code is altered compared to the original in order to create a minimal reproducer

## Problem 1

Problem with inheritance of the `final` method.
This problem has been around for a long time with the Cray compiler cce/8.7 at least

Consider following Fortran code:

```f90
module object_module

    type :: Object
    contains
        final :: destructor
    endtype

    type, extends(Object) :: ObjectDerived
    contains
    endtype

    type, extends(Object) :: ObjectDerivedWithDummyFinal
    contains
        final :: destructor_ObjectDerivedWithDummyFinal
    endtype

contains

    subroutine destructor(this)
        type(Object) :: this
        write(0,*) 'destructor called'
    end subroutine

    subroutine destructor_ObjectDerivedWithDummyFinal(this)
        type(ObjectDerivedWithDummyFinal) :: this
        ! dummy, just so destructor will be called
    end subroutine

end module
```

When instance of `ObjectDerived` leaves scope, the 'destructor' subroutine from 'Object' should get called but it doesn't.
A workaround seems to be creating a dummy 'final' routine which is empty such as done in `ObjectDerivedWithDummyFinal`

### Instructions to reproduce error:

Environment on LUMI:

    source env/lumi/cce-15.sh

Compile:

    rm -rf build
    cmake -S . -B build
    cmake --build build --target test_inherit_final

    build/bin/test_inherit_final


## Problem 2

The second problem is observed running an executable compiled with cce/15.0.1 on LUMI:

    lib-4220 : UNRECOVERABLE library error
    An internal library run time error has occurred.

It involves compilation of 2 mixed C++/Fortran libraries:

- `libfckit_lite.so` library linked with `CC` (c++)
- `libatlas_lite.so` library linked with `CC` (c++) and linking to `libfckit_lite.so`
- `test_atlas_lite`  executable is a Fortran executable linking to `libatlas_lite.so`

Problem does not occur when:

- compiling static libraries
- compiling `libatlas_lite.so` with `ftn` instead
- code changes in 'libfckit_lite.so`

These workarounds have been added to the reproducer via CMake options (see below)

A default-ON workaround for Problem 1, which can be disabled has been added to `libatlas_lite.so`
but ideally needs to be removed.

### Instructions to reproduce error:

Environment on LUMI:

    source env/lumi/cce-15.sh

Compile:

    rm -rf build
    cmake -S . -B build ${CMAKE_ARGS}
    cmake --build build

When `CMAKE_ARGS` is undefined, this is equivalent to

    CMAKE_ARGS="-DENABLE_FINAL=ON -DBUILD_SHARED_LIBS=ON -DENABLE_CXX_LINKER=ON -DENABLE_CRAY_WORKAROUND=OFF -DENABLE_DEBUG_OUTPUT=OFF"

Run:

    build/bin/test_atlas_lite

Also `ctest` can be used instead to automatically run the tests of Problem 1 and Problem 2

    ctest --verbose --test-dir build

### Extra requirement

- Above should work, both with `-DENABLE_FINAL=ON` and `-DENABLE_FINAL=OFF` !!!
- When Problem 1 is fixed, we should be able to use `-DENABLE_OBJECT_FINAL_AUTO=OFF` (default=ON).
  This introduced a undesired code change in derived types in `libatlas_lite.so`

### Known workarounds

Three different methods have been succesful but unsatisfactory in working around the problem, and could help to
understand the underlying problem.

Repeat above command by adding some cmake options 

1. Compilation with static libraries, NOT DESIRED

        CMAKE_ARGS="-DBUILD_SHARED_LIBS=OFF"

2. Compilation of library `libatlas_lite.so` with Fortran linker, NOT DESIRED!

        CMAKE_ARGS="-DENABLE_CXX_LINKER=OFF"

    This uses `ftn` instead of `CC` to link the intermediate library `libatlas_lite.so`

3. Compilation with code changes, NOT DESIRED

        CMAKE_ARGS="-DENABLE_CRAY_WORKAROUND=ON"

   This enables code changes, which avoid type-bound procedures but should not be necessary.

# Comparisons

### Platform/Compilers known to work:

- ecmwf-hpc2020 | gnu 8.5
- ecmwf-hpc2020 | gnu 13.1
- ecmwf-hpc2020 | intel 2021.4
- ecmwf-hpc2020 | intel 2023.2
- ecmwf-hpc2020 | nvidia 22.11

### Platform/Compilers known to fail:

- LUMI | cce 14.0.2
- LUMI | cce 15.0.1
