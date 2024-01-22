! (C) Copyright 2013 ECMWF.
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation nor
! does it submit to any jurisdiction.


module fckit_configuration_module
  !! author: Willem Deconinck

use, intrinsic :: iso_c_binding, only : c_ptr, c_int32_t, c_size_t, c_char, c_funloc
use fckit_shared_object_module, only : fckit_shared_object

implicit none

public  :: fckit_configuration
public  :: deallocate_fckit_configuration
public  :: fckit_configurations_alive

private

#include "fckit_configuration.inc"

!----------------------------------------------------------------------------
TYPE, extends(fckit_shared_object) :: fckit_configuration
contains

#ifndef NO_AUTOFINAL
  final :: fckit_configuration__final_auto
    !> Without this the 'final' from base class fckit_shared_object does not get called
#endif

  procedure, public :: get_config_list

  procedure :: json
END TYPE fckit_configuration

!------------------------------------------------------------------------------

interface fckit_configuration
  module procedure fckit_configuration__new
end interface

!------------------------------------------------------------------------------

private :: c_ptr, c_int32_t, c_size_t, c_char, c_funloc
private :: fckit_shared_object

!========================================================
contains
!========================================================

! -----------------------------------------------------------------------------
! Config routines

subroutine deallocate_fckit_configuration( array )
  type(fckit_configuration), allocatable, intent(inout) :: array(:)
  integer(c_int32_t) :: j
  if( allocated(array) ) then
    write(0,*) "  deallocate_fckit_configuration()"
    do j=1,size(array)
      write(0,'(A,I0,A)') "     + call array(",j,")%final()"
      call array(j)%final()
    enddo
    write(0,*) "    + deallocate(array)"
    deallocate(array)
  endif
end subroutine

impure elemental subroutine fckit_configuration__final_auto(this)
  type(fckit_configuration), intent(inout) :: this
  ! Without this routine, the 'final' from base class fckit_shared_object does not get called
  ! Note, only with Cray compiler. Already reported to HPE.

  write(0,*) "fckit_configuration__final_auto  ", this%id
end subroutine

function fckit_configuration__new() result(this)
  type(fckit_Configuration) :: this
  write(0,*) "  fckit_configuration__new()"
  call this%reset_c_ptr( c_fckit_configuration_new(), c_funloc(c_fckit_configuration_delete) )
  this%id = "rhs"
end function


subroutine get_config_list(this, length, value)
  use, intrinsic :: iso_c_binding, only : c_f_pointer, c_null_ptr, c_int
  logical :: found
  class(fckit_Configuration), intent(in) :: this
  integer(c_int), intent(in) :: length
  type(fckit_Configuration), allocatable, intent(inout) :: value(:)
  type(c_ptr) :: value_list_cptr
  type(c_ptr), pointer :: value_cptrs(:)
  integer(c_int32_t) :: found_int
  integer(c_size_t) :: j
  character(len=4) :: str
  write(0,*) "  get_config_list"
  call deallocate_fckit_configuration(value)
  value_list_cptr = c_null_ptr
  call c_fckit_configuration_get_config_list(this%c_ptr(), length, &
    & value_list_cptr)
  found = .true.
    call c_f_pointer(value_list_cptr,value_cptrs,(/length/))
    allocate(value(length))
    do j=1,length
      call value(j)%reset_c_ptr( value_cptrs(j), c_funloc(c_fckit_configuration_delete) )
      write(str,'(I0)') j
      value(j)%id = 'array('//trim(str)//')'
    enddo
end subroutine

function json(this) result(jsonstr)
  use fckit_c_interop_module, only : c_ptr_to_string, c_ptr_free
  character(kind=c_char,len=:), allocatable :: jsonstr
  class(fckit_Configuration), intent(in) :: this
  type(c_ptr) :: json_cptr
  integer(c_size_t) :: json_size
  call c_fckit_configuration_json(this%c_ptr(),json_cptr,json_size)
  allocate( character(len=(json_size)) :: jsonstr )  
  jsonstr = c_ptr_to_string(json_cptr)
  call c_ptr_free(json_cptr)
end function

end module fckit_configuration_module
