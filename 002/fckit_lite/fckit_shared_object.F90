! (C) Copyright 2013 ECMWF.
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation nor
! does it submit to any jurisdiction.

#define __FILENAME__ "fckit_shared_object.F90"

module fckit_shared_object_module
use iso_c_binding, only : c_ptr, c_funptr, c_null_ptr, c_null_funptr, c_f_procpointer, c_associated, c_loc

implicit none
private

integer, save :: count_final_auto = 0
integer, save :: count_final_auto_max = 30 
  !> For this reproducer we are never supposed to allocate 
  !  and deallocate more than a handful

!========================================================================
! Public interface

public :: fckit_shared_object

!========================================================================

type :: fckit_shared_object
  type(c_ptr), private :: cptr = c_null_ptr
  type(c_funptr) :: cdeleter = c_null_funptr
  character(len=20) :: id = "uninitialized"

contains

  procedure, public :: reset_c_ptr

  procedure, public  :: c_ptr => fckit_shared_object_c_ptr

#ifndef NO_AUTOFINAL
  final :: fckit_shared_object__final_auto
#endif

  procedure, public :: final => fckit_shared_object__final

#ifdef __GFORTRAN__
  procedure, private :: assignment_operator
  generic, public :: assignment(=) => assignment_operator
#endif

end type

!========================================================================
CONTAINS
!========================================================================

subroutine assignment_operator(this,other)
  class(fckit_shared_object), intent(inout) :: this
  class(fckit_shared_object), intent(in)    :: other
  call this%final()
  this%cptr = other%cptr
  this%cdeleter = other%cdeleter
  this%id = other%id
end subroutine


subroutine fckit_shared_object__final(this)
  use fckit_c_interop_module, only : fckit_c_deleter_interface
  class(fckit_shared_object), intent(inout) :: this
  procedure(fckit_c_deleter_interface), pointer :: deleter
  write(0,'(A,I3,A,A)') "     "//__FILENAME__//" @ ",__LINE__," : fckit_shared_object__final     , id: ", this%id
  if( c_associated(this%cptr) .and. c_associated(this%cdeleter) .and. trim(this%id) /= "rhs") then
    call c_f_procpointer(this%cdeleter, deleter)
    write(0,'(A,I3,A)') "     "//__FILENAME__//" @ ",__LINE__," :  call deleter(this%cptr)"
    call deleter(this%cptr)
    this%cptr = c_null_ptr
    this%cdeleter = c_null_funptr
  endif
    
end subroutine

impure elemental subroutine fckit_shared_object__final_auto(this)
  use, intrinsic :: iso_c_binding, only : c_loc, c_null_ptr
  use fckit_c_interop_module, only : c_ptr_to_loc
  type(fckit_shared_object), target, intent(inout) :: this

  write(0,'(A,I3,A,I0)') "     "//__FILENAME__//" @ ",__LINE__," : fckit_shared_object__final_auto, address: ",&
          & c_ptr_to_loc(c_loc(this))

  !----------------------------------------------------------------------
  ! Bad addresses only seem to occur with cray compiler.
  ! Trying to avoid SEGFAULT for BAD addresses and instead try to detect infinite loop
  ! to exit a little more gracefully with error message.
  ! Sometimes this does not work, and SEGFAULT happens instead.
      count_final_auto = count_final_auto + 1
      if (count_final_auto > count_final_auto_max) then
        write(0,*) "    ..."
        write(0,*) "    Infinite loop, abort at fckit_shared_object.F90 @ line ", __LINE__
        stop 1
      endif

      if( c_ptr_to_loc(c_loc(this)) < 1000000 ) then
        return
      endif
  !----------------------------------------------------------------------

  call this%final()
end subroutine


subroutine reset_c_ptr(this, cptr, deleter )
  use, intrinsic :: iso_c_binding, only : c_ptr, c_funptr
  implicit none
  class(fckit_shared_object) :: this
  type(c_ptr) :: cptr
  type(c_funptr) :: deleter
  this%id = ""
  write(0,'(A,I3,A)') "     "//__FILENAME__//" @ ",__LINE__, " : reset_c_ptr"
  this%cptr = cptr
  this%cdeleter = deleter
end subroutine


function fckit_shared_object_c_ptr(this) result(cptr)
  use, intrinsic :: iso_c_binding, only : c_ptr
  type(c_ptr) :: cptr
  class(fckit_shared_object) :: this
  cptr = this%cptr
end function

end module
