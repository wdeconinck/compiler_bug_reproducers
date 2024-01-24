# (C) Copyright 2013 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

add_library( atlas_lite
  atlas_object.cc
  atlas_object_c_binding.F90
  atlas_object.F90
)
if (ENABLE_CXX_LINKER)
  set_target_properties( atlas_lite PROPERTIES LINKER_LANGUAGE CXX )

  if (ENABLE_PROPOSED_LINK_OPTION)
    message("" )
    message("ENABLE_PROPOSED_LINK_OPTION=ON --> setting proposed extra linker flag [-fuse-ld=bfd] to workaround Cray compiler bug")
    target_link_options( atlas_lite PRIVATE "-fuse-ld=bfd")
  endif()
else()
  set_target_properties( atlas_lite PROPERTIES LINKER_LANGUAGE Fortran )
endif()

target_link_libraries( atlas_lite PUBLIC fckit_lite )

