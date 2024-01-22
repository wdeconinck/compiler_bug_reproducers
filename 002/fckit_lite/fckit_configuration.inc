! (C) Copyright 2013 ECMWF.
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation nor
! does it submit to any jurisdiction.

#ifndef FORD
interface

function fckit_configurations_alive() bind(C,name="fckit_configurations_alive")
  use iso_c_binding, only: c_int
  integer(c_int) :: fckit_configurations_alive
end function

!-------------------------------------------------------------------------------
! Configuration* c_fckit_configuration_new ()
!-------------------------------------------------------------------------------
function c_fckit_configuration_new() bind(C,name="c_fckit_configuration_new")
    use iso_c_binding, only: c_ptr
    type(c_ptr) :: c_fckit_configuration_new
end function
!-------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
! void c_fckit_configuration_delete (Configuration* This)
!-------------------------------------------------------------------------------
subroutine c_fckit_configuration_delete( This ) bind(C,name="c_fckit_configurat&
  &ion_delete")
    use iso_c_binding, only: c_ptr
    type(c_ptr), value :: This
end subroutine
!-------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
! void c_fckit_configuration_get_config_list (const Configuration* This, const
!   int size, LocalConfiguration** &value, size_t &size)
!-------------------------------------------------------------------------------
subroutine c_fckit_configuration_get_config_list( This, size, value ) bind(&
  &C,name="c_fckit_configuration_get_config_list")
    use iso_c_binding, only: c_char, c_ptr, c_int32_t, c_size_t
    type(c_ptr), value :: This
    integer(c_int32_t), value :: size
    type(c_ptr) :: value
end subroutine
!-------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
! void c_fckit_configuration_json(const Configuration* This, char* &json, int &s
!   ize)
!-------------------------------------------------------------------------------
subroutine c_fckit_configuration_json( This, json, size ) bind(C,name="c_fckit_&
  &configuration_json")
    use iso_c_binding, only: c_ptr, c_size_t
    type(c_ptr), value :: This
    type(c_ptr) :: json
    integer(c_size_t) :: size
end subroutine
!-------------------------------------------------------------------------------

end interface
#endif
