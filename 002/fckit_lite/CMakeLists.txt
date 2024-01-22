# (C) Copyright 2013 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

set( fckit_src
    fckit_C_interop.cc
    fckit_C_interop.F90
    fckit_shared_object.F90
    fckit_configuration.F90
    fckit_configuration.cc
)

add_library(fckit_autofinal SHARED ${fckit_src})
set_target_properties(fckit_autofinal PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/module/fckit_autofinal)
target_include_directories(fckit_autofinal PUBLIC ${CMAKE_BINARY_DIR}/module/fckit_autofinal)

add_library(fckit SHARED ${fckit_src})
set_target_properties(fckit PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/module/fckit)
target_include_directories(fckit PUBLIC ${CMAKE_BINARY_DIR}/module/fckit)
target_compile_definitions(fckit INTERFACE PUBLIC NO_AUTOFINAL)
