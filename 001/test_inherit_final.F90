! (C) Copyright 2013 ECMWF.
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation nor
! does it submit to any jurisdiction.



! This file is used in conjunction with final-support.cmake to detect compiler behaviour
! for the finalisation of derived types



module final_support_module
implicit none
public
integer, parameter :: output_unit = 6

type :: Object
  logical, public :: return = .false.
  logical, public :: initialized = .false.
  logical, public :: finalized = .false.
contains
  procedure, public :: copy => copy_f
  generic, public :: assignment(=) => copy
  final :: destructor
endtype

interface Object
  module procedure construct_Object
end interface

type, extends(Object) :: ObjectDerivedWithFinal
contains
  final :: destructor_ObjectDerivedWithFinal
endtype

interface ObjectDerivedWithFinal
  module procedure construct_ObjectDerivedWithFinal
end interface

type, extends(Object) :: ObjectDerivedWithoutFinal
contains
endtype

interface ObjectDerivedWithoutFinal
  module procedure construct_ObjectDerivedWithoutFinal
end interface


integer :: final_uninitialized = 0
integer :: final_return        = 0
integer :: final_initialized   = 0
integer :: final_base         = 0
integer :: final_derived       = 0
integer :: indent=0

contains

subroutine reset()
  final_uninitialized = 0
  final_return        = 0
  final_initialized   = 0
  final_base          = 0
  final_derived       = 0
end subroutine

subroutine write_indented( string )
  character(len=*) :: string
  integer :: i
  do i=1,indent
    write(0,'(A)',advance='no') '  '
  enddo
  write(0,'(A)') string
end subroutine
subroutine write_counters()
  write(0,*) ''
  write(0,*) 'final_uninitialized: ',final_uninitialized
  write(0,*) 'final_initialized:   ',final_initialized
  write(0,*) 'final_return:        ',final_return
  write(0,*) 'final_base:          ',final_base
  write(0,*) 'final_derived:       ',final_derived
end subroutine

function construct_Object() result(this)
  type(Object) :: this
  this%initialized = .true.
  this%return = .true.
end function

function construct_ObjectDerivedWithFinal() result(this)
  type(ObjectDerivedWithFinal) :: this
  this%initialized = .true.
  this%return = .true.
end function

function construct_ObjectDerivedWithoutFinal() result(this)
  type(ObjectDerivedWithoutFinal) :: this
  this%initialized = .true.
  this%return = .true.
end function

subroutine destructor_ObjectDerivedWithFinal(this)
  type(ObjectDerivedWithFinal) :: this
  call write_indented( 'final( derived )' )
  final_derived = final_derived + 1
  associate( unused => this )
  end associate
end subroutine

subroutine copy_f(this,obj_in)
  class(Object), intent(inout) :: this
  class(Object), target, intent(in) :: obj_in
#if 1
  if( obj_in%return ) then
     if( .not. this%initialized ) then
        call write_indented( 'copy uninitialized from rvalue' )
     else
        call write_indented( 'copy initialized from rvalue' )
     endif
  else if ( obj_in%initialized ) then
     if( .not. this%initialized ) then
        call write_indented( 'copy uninitialized from already existing initialized' )
     else
        call write_indented( 'copy initialized from already existing initialized' )
     endif
  endif
#endif
  this%initialized = obj_in%initialized
  this%return = .false.
end subroutine

impure elemental subroutine destructor(this)
  type(Object), intent(inout) :: this
  final_base = final_base + 1

  if( .not. this%initialized ) then
    call write_indented( 'final( uninitialized )' )
    final_uninitialized = final_uninitialized+1
  else
    if( this%return ) then
      call write_indented( 'final( returned )' )
      final_return = final_return+1
    else
      call write_indented( 'final( initialized )' )
      final_initialized = final_initialized+1
    endif
  endif
end subroutine


subroutine create_obj_out(obj)
  implicit none
  type(Object), intent(out) :: obj
  call write_indented( 'obj = Object()' )
  indent = indent+1
  obj = Object()
  indent = indent-1
end subroutine

subroutine create_obj_inout(obj)
  implicit none
  type(Object), intent(inout) :: obj
  call write_indented( 'obj = Object()' )
  indent = indent+1
  obj = Object()
  indent = indent-1
end subroutine


subroutine test
  implicit none
  type(ObjectDerivedWithoutFinal) :: obj
  indent = indent+1
  obj = ObjectDerivedWithoutFinal()
  indent = indent-1
  call write_indented('--- scope end ---')
end subroutine

subroutine run_test
  write(0,'(A)') '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  call write_indented( 'subroutine test' )
  indent = indent+1
  call reset
  call test
  indent = indent-1
  call write_indented( 'end subroutine test' )
  write(0,'(A)') '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  
  write(0,*) ""
  write(0,*) "Counters:"
  call write_counters()
end subroutine


end module


program final_support
  use final_support_module
  implicit none

  call run_test
  if( final_initialized == 0 ) then
    write(0,*) ""
    write(0,*) "TEST FAILED: final was not inherited (final_initialized == 0)"
    stop 1
  endif

end program
