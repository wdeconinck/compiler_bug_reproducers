#define __FILENAME__ "atlas_object.F90"

module atlas_object_module

use fckit_owned_object_module, only: fckit_owned_object

implicit none

public :: Object
public :: object_destroyed

private

!------------------------------------------------------------------------------
TYPE, extends(fckit_owned_object) :: Object
contains
  procedure, public :: create_object
#ifdef ENABLE_OBJECT_FINAL_AUTO
  ! Adding empty finalisation method to workaround Cray compiler bug
  ! which would prevent the base auto final to be called
  final :: Object__final_auto
#endif
  procedure, public :: assignment_operator_hook => Object__assignment_operator_hook

END TYPE

interface Object
  module procedure Object__ctor_id
end interface

!========================================================
contains
!========================================================

function object_destroyed(id) result(destroyed)
  use atlas_object_c_binding
  integer :: id
  logical :: destroyed
  destroyed = .false.
  if (Object__destroyed(id) == 1) then
    destroyed = .true.
  endif
end function

function create_object(this,id) result(obj)
  use atlas_object_c_binding
  class(Object), intent(in) :: this
  integer :: id
  type(fckit_owned_object) :: obj
  call obj%reset_c_ptr( new_Object(id) )
  call Object__set_other(obj%c_ptr(), this%c_ptr())
  call obj%return()
end function

! -----------------------------------------------------------------------------
! Destructor

! This is the case for cray compiler cce/15
impure elemental subroutine Object__final_auto(this)
  type(Object), intent(inout) :: this
#ifdef ENABLE_DEBUG_OUTPUT
  write(0,'(A,A,I0,A)') __FILENAME__ , " @ ", __LINE__, " :  Object__final_auto"
#endif
end subroutine

! -----------------------------------------------------------------------------
! Constructors

function Object__ctor_id(identifier) result(this)
  use atlas_object_c_binding
  use, intrinsic :: iso_c_binding, only : c_ptr
  type(Object) :: this
  integer, intent(in) :: identifier
  type(c_ptr) :: cptr
#ifdef ENABLE_DEBUG_OUTPUT 
  write(0,'(A,A,I0,A)') __FILENAME__ , " @ ", __LINE__, " :  Object__ctor_id begin"
#endif
  cptr = new_Object(identifier)
#ifdef ENABLE_DEBUG_OUTPUT 
  write(0,'(A,A,I0,A)') __FILENAME__ , " @ ", __LINE__, " :  Object__ctor_id begin"
  write(0,'(A,A,I0,A)') __FILENAME__ , " @ ", __LINE__, " :  this%reset_c_ptr(  )"
#endif
  call this%reset_c_ptr( cptr )
#ifdef ENABLE_DEBUG_OUTPUT 
  write(0,'(A,A,I0,A)') __FILENAME__ , " @ ", __LINE__, " :  this%return()"
#endif
  call this%return()
#ifdef ENABLE_DEBUG_OUTPUT 
  write(0,'(A,A,I0,A)') __FILENAME__ , " @ ", __LINE__, " :  Object__ctor_id end"
#endif
end function

! -----------------------------------------------------------------------------

subroutine Object__assignment_operator_hook(this, other)
  use atlas_object_c_binding
  class(Object) :: this
  class(fckit_owned_object) :: other
#ifdef ENABLE_DEBUG_OUTPUT 
  write(0,'(A,A,I0,A,I0)') __FILENAME__, " @ ", __LINE__, " :  Object__assignment_operator_hook for Object ", &
      & Object__id(this%c_ptr())
#endif
end subroutine
  
end module


