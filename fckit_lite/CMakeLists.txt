# (C) Copyright 2013 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

add_library( fckit_lite
           fckit_owned.cc
           fckit_owned.h
           fckit_owned_object.F90
           fckit_C_interop.cc
           fckit_C_interop.F90
)
set_target_properties( fckit_lite PROPERTIES LINKER_LANGUAGE CXX )
target_include_directories( fckit_lite PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> )

