
module atlas_object_c_binding

implicit none

public

interface
    function new_Object(i) bind(c,name="new_Object")
      use, intrinsic :: iso_c_binding, only : c_ptr, c_int32_t
      type(c_ptr) :: new_Object
      integer(c_int32_t), value :: i
    end function

    subroutine delete_Object(cptr) bind(c,name="delete_Object")
      use, intrinsic :: iso_c_binding, only : c_ptr
      type(c_ptr), value :: cptr
    end subroutine
 

    subroutine Object__set_other(this,other) bind(c,name="Object__set_other")
      use, intrinsic :: iso_c_binding, only : c_ptr
      type(c_ptr), value :: this
      type(c_ptr), value :: other
    end subroutine
 
    function Object__id(cptr) bind(c,name="Object__id") result(id)
      use, intrinsic :: iso_c_binding, only : c_ptr, c_int32_t
      type(c_ptr), value :: cptr
      integer(c_int32_t) :: id
    end function

    function Object__destroyed(i) bind(c,name="Object__destroyed") result(destroyed)
      use, intrinsic :: iso_c_binding, only : c_int32_t
      integer(c_int32_t), value :: i
      integer(c_int32_t) :: destroyed
    end function

end interface

contains

end module
