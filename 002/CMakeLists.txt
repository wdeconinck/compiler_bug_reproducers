# (C) Copyright 2013 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

cmake_minimum_required( VERSION 3.12 FATAL_ERROR )

project( reproducer LANGUAGES C CXX Fortran )

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

################################################################################################
# sources

add_subdirectory( fckit_lite )

add_executable(reproducer_unallocated reproducer.F90)
target_link_libraries(reproducer_unallocated fckit_autofinal)

add_executable(reproducer_unallocated_manual_final reproducer.F90)
target_link_libraries(reproducer_unallocated_manual_final fckit_autofinal)
target_compile_definitions(reproducer_unallocated_manual_final PUBLIC MANUAL_FINAL)

add_executable(reproducer_allocate_zero reproducer.F90)
target_link_libraries(reproducer_allocate_zero fckit_autofinal)
target_compile_definitions(reproducer_allocate_zero PUBLIC ALLOCATE_ZERO)

add_executable(reproducer_assign reproducer.F90)
target_link_libraries(reproducer_assign fckit_autofinal)
target_compile_definitions(reproducer_assign PUBLIC ASSIGN)

add_executable(reproducer_assign_manual_final reproducer.F90)
target_link_libraries(reproducer_assign_manual_final fckit_autofinal)
target_compile_definitions(reproducer_assign_manual_final PUBLIC ASSIGN MANUAL_FINAL)

add_executable(reproducer_assign_manual_final_no_autofinal reproducer.F90)
target_link_libraries(reproducer_assign_manual_final_no_autofinal fckit)
target_compile_definitions(reproducer_assign_manual_final_no_autofinal PUBLIC ASSIGN MANUAL_FINAL)

enable_testing()

foreach( executable reproducer_unallocated reproducer_unallocated_manual_final reproducer_allocate_zero reproducer_assign reproducer_assign_manual_final reproducer_assign_manual_final_no_autofinal)
  add_test(NAME ${executable} COMMAND ${executable} )
endforeach()

