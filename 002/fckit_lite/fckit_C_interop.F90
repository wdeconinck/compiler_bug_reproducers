! (C) Copyright 2013 ECMWF.
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation nor
! does it submit to any jurisdiction.

module fckit_C_interop_module
implicit none
private

!========================================================================
! Public interface

public :: c_ptr_free
public :: c_ptr_to_loc
public :: c_ptr_to_string
public :: fckit_c_deleter_interface

! =============================================================================
! External functions

interface

  subroutine c_ptr_free(ptr) bind(c, name="fckit__cptr_free")
    use, intrinsic :: iso_c_binding, only: c_ptr
    type(c_ptr), value :: ptr
  end subroutine

  function fckit__cptr_to_loc(cptr) bind(c,name="fckit__cptr_to_loc") result(loc)
    use, intrinsic :: iso_c_binding, only: c_ptr, c_int64_t
    integer(c_int64_t) :: loc
    type(c_ptr), value :: cptr
  end function
end interface

abstract interface
  subroutine fckit_c_deleter_interface(cptr) bind(c)
    use, intrinsic :: iso_c_binding
    type(c_ptr), value :: cptr
  end subroutine
end interface

! =============================================================================
CONTAINS
! =============================================================================

function c_ptr_to_loc(cptr) result(loc)
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int64_t
  integer(c_int64_t) :: loc
  type(c_ptr), intent(in) :: cptr
  loc = fckit__cptr_to_loc(cptr)
end function

! =============================================================================

subroutine copy_c_str_to_string(s,string)
  use, intrinsic :: iso_c_binding
  character(kind=c_char,len=1), intent(in) :: s(*)
  character(len=:), allocatable :: string
  integer i, nchars
  i = 1
  do
     if (s(i) == c_null_char) exit
     i = i + 1
  enddo
  nchars = i - 1  ! Exclude null character from Fortran string
  allocate( character(len=(nchars)) :: string )  
  do i=1,nchars
    string(i:i) = s(i)
  enddo
end subroutine

! =============================================================================

function c_ptr_to_string(cptr) result(string)
  use, intrinsic :: iso_c_binding
  type(c_ptr), intent(in) :: cptr
  character(kind=c_char,len=:), allocatable :: string
  character(kind=c_char), dimension(:), pointer  :: s
  integer(c_int), parameter :: MAX_STR_LEN = 255
  call c_f_pointer ( cptr , s, (/MAX_STR_LEN/) )
  call copy_c_str_to_string( s, string )
end function

! =============================================================================

end module
