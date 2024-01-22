# (C) Copyright 2013 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

cmake_minimum_required( VERSION 3.12 FATAL_ERROR )

project( atlas_lite LANGUAGES C CXX Fortran )

set(CMAKE_DIRECTORY_LABELS "fckit")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/module )

option( ENABLE_FINAL "Enable final" ON )
option( ENABLE_CXX_LINKER "Enable CXX linker" ON )
option( ENABLE_DEBUG_OUTPUT "Enable debug output" OFF )
option( ENABLE_CRAY_WORKAROUND "Enable workaround" OFF )
option( BUILD_SHARED_LIBS "Build shared libs" ON )
option( ENABLE_OBJECT_FINAL_AUTO "Enable workaround for Cray bug with inheriting final" ON )


message("")
message("Configuration:")
message("   ENABLE_FINAL             : ${ENABLE_FINAL}")
message("   ENABLE_DEBUG_OUTPUT      : ${ENABLE_DEBUG_OUTPUT}")
message("   ENABLE_CXX_LINKER        : ${ENABLE_CXX_LINKER}")
message("   ENABLE_CRAY_WORKAROUND   : ${ENABLE_CRAY_WORKAROUND}" )
message("   BUILD_SHARED_LIBS        : ${BUILD_SHARED_LIBS}" )
message("   ENABLE_OBJECT_FINAL_AUTO : ${ENABLE_OBJECT_FINAL_AUTO}" )

if( ENABLE_DEBUG_OUTPUT )
  add_compile_definitions("ENABLE_DEBUG_OUTPUT")
endif()
if( ENABLE_CRAY_WORKAROUND )
  add_compile_definitions("ENABLE_CRAY_WORKAROUND")
endif()
if ( ENABLE_OBJECT_FINAL_AUTO )
  add_compile_definitions("ENABLE_OBJECT_FINAL_AUTO")
endif()


if( ENABLE_FINAL )
  add_compile_definitions("ENABLE_FINAL")
endif()

add_executable( test_inherit_final test_inherit_final.F90 )

add_subdirectory( fckit_lite )
add_subdirectory( atlas_lite )

add_executable( test_atlas_lite test_atlas_lite.F90 )
target_link_libraries( test_atlas_lite PUBLIC atlas_lite )

if( ENABLE_OBJECT_FINAL_AUTO )
message("")
message("WARNING: ENABLE_OBJECT_FINAL_AUTO=ON, this is not desired but a workaround necessary for Cray")
endif()

include(CTest)
add_test( NAME test_inherit_final  COMMAND test_inherit_final)
add_test( NAME test_atlas_lite     COMMAND test_atlas_lite)

message("")
message("Run all tests via `ctest`, or individually:")
message("")
message("    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/test_inherit_final")
message("    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/test_atlas_lite")
message("")
