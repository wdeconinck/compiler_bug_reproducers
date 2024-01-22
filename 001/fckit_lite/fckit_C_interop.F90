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
public :: c_ptr_compare_equal
public :: c_ptr_to_loc
public :: c_str_to_string
public :: c_ptr_to_string
public :: copy_c_ptr_to_string
public :: copy_c_str_to_string
public :: c_str
public :: c_str_no_trim
public :: c_str_right_trim
public :: fckit_c_deleter_interface
public :: fckit_c_deleter
public :: fckit_c_nodeleter

! =============================================================================
! External functions

interface

  subroutine c_ptr_free(ptr) bind(c, name="fckit__cptr_free")
    use, intrinsic :: iso_c_binding, only: c_ptr
    type(c_ptr), value :: ptr
  end subroutine

  !int fckit__compare_cptr_equal( void* p1, void* p2 )
  function fckit__compare_cptr_equal(p1,p2) bind(c,name="fckit__compare_cptr_equal") result(equal)
    use, intrinsic :: iso_c_binding, only: c_ptr, c_int32_t
    integer(c_int32_t) :: equal
    type(c_ptr), value :: p1
    type(c_ptr), value :: p2
  end function

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

function fckit_c_deleter( deleter )
  use, intrinsic :: iso_c_binding, only : c_funloc, c_funptr
  type(c_funptr) :: fckit_c_deleter
  procedure(fckit_c_deleter_interface) :: deleter
  fckit_c_deleter = c_funloc(deleter)
end function

subroutine fckit_c_nodelete(cptr) bind(c)
  use, intrinsic :: iso_c_binding
  type(c_ptr), value :: cptr
end subroutine

function fckit_c_nodeleter()
  use, intrinsic :: iso_c_binding, only : c_funloc, c_funptr
  type(c_funptr) :: fckit_c_nodeleter
  fckit_c_nodeleter = c_funloc(fckit_c_nodelete)
end function

function c_ptr_compare_equal(p1,p2) result(equal)
  use, intrinsic :: iso_c_binding, only: c_ptr
  logical :: equal
  type(c_ptr), intent(in) :: p1, p2
  if( fckit__compare_cptr_equal(p1,p2) == 1 ) then
    equal = .True.
  else
    equal = .False.
  endif
end function

function c_ptr_to_loc(cptr) result(loc)
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int64_t
  integer(c_int64_t) :: loc
  type(c_ptr), intent(in) :: cptr
  loc = fckit__cptr_to_loc(cptr)
end function

! =============================================================================

function c_str_to_string(s) result(string)
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
  allocate( character(len=nchars,kind=c_char) :: string )
  do i=1,nchars
    string(i:i) = s(i)
  enddo
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
  allocate( character(len=nchars,kind=c_char) :: string )
  do i=1,nchars
    string(i:i) = s(i)
  enddo
end subroutine

! =============================================================================

subroutine copy_c_ptr_to_string(cptr,string)
  use, intrinsic :: iso_c_binding
  type(c_ptr), intent(in) :: cptr
  character(kind=c_char,len=:), allocatable :: string
  character(kind=c_char), dimension(:), pointer  :: s
  integer(c_int), parameter :: MAX_STR_LEN = 255
  call c_f_pointer ( cptr , s, (/MAX_STR_LEN/) )
  call copy_c_str_to_string( s, string )
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

function c_str(f_str)
  use, intrinsic :: iso_c_binding, only: c_char, c_null_char
  character(kind=c_char,len=*), intent(in) :: f_str
  character(kind=c_char,len=len_trim(f_str)+1) :: c_str
  c_str = trim(f_str) // c_null_char
end function

! =============================================================================

function c_str_no_trim(f_str)
  use, intrinsic :: iso_c_binding, only: c_char, c_null_char
  character(kind=c_char,len=*), intent(in) :: f_str
  character(kind=c_char,len=len(f_str)+1) :: c_str_no_trim
  c_str_no_trim = f_str // c_null_char
end function

! =============================================================================

function c_str_right_trim(f_str)
  use, intrinsic :: iso_c_binding, only: c_char, c_null_char
  character(kind=c_char,len=*), intent(in) :: f_str
  character(kind=c_char,len=len(f_str)+1) :: c_str_right_trim
  c_str_right_trim = f_str(1:len_trim(f_str)) // c_null_char
end function

! =============================================================================

! Callback function, used from C++ side
subroutine fckit_write_to_fortran_unit(unit,msg_cptr) bind(C)
  use, intrinsic :: iso_c_binding, only: c_int32_t, c_ptr, c_char, c_associated
  !use fckit_c_interop_module, only : copy_c_ptr_to_string
  integer(c_int32_t), value, intent(in) :: unit
  type(c_ptr), value, intent(in) :: msg_cptr
  character(kind=c_char,len=:), allocatable :: msg
  if( c_associated(msg_cptr) ) then
    call copy_c_ptr_to_string( msg_cptr, msg )
    write(unit,'(A)') msg
  endif
end subroutine

function fckit_fortranunit_stdout() result(stdout) bind(C)
  use, intrinsic :: iso_c_binding, only : c_int32_t
  use, intrinsic :: iso_fortran_env, only : output_unit
  integer(c_int32_t) :: stdout
  stdout = output_unit
end function

function fckit_fortranunit_stderr() result(stderr) bind(C)
  use, intrinsic :: iso_c_binding, only : c_int32_t
  use, intrinsic :: iso_fortran_env, only : error_unit
  integer(c_int32_t) :: stderr
  stderr = error_unit
end function


end module
