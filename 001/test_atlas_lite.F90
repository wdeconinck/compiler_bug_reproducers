! (C) Copyright 2013 ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation nor
! does it submit to any jurisdiction.

program main
    use atlas_object_module, only : object_destroyed

    logical :: success
    logical :: autofinal

    success = .true.
    autofinal = .false.


    write(0,'(A)') "--------------------------------------------------------------"
    write(0,'(A)') "test_1 with manual finalisation"
    write(0,'(A)') "--------------------------------------------------------------"
    call test_1
    if (.not. object_destroyed(11)) then
        success = .false.
        write(0,'(A)') "Object 11 was not destroyed"
    endif

    write(0,'(A)') "--------------------------------------------------------------"
    write(0,'(A)') "test_2 with manual finalisation"
    write(0,'(A)') "--------------------------------------------------------------"
    call test_2
    if (.not. object_destroyed(21)) then
        success = .false.
        write(0,'(A)') "Object 21 was not destroyed"
    endif
    if (.not. object_destroyed(22)) then
        success = .false.
        write(0,'(A)') "Object 22 was not destroyed"
    endif

#ifdef ENABLE_FINAL
    autofinal = .true.
    write(0,'(A)') "--------------------------------------------------------------"
    write(0,'(A)') "test_1 with automatic finalisation"
    write(0,'(A)') "--------------------------------------------------------------"
    call test_1
    if (.not. object_destroyed(11)) then
        success = .false.
        write(0,'(A)') "Object 11 was not destroyed"
    endif

    write(0,'(A)') "--------------------------------------------------------------"
    write(0,'(A)') "test_2 with automatic finalisation"
    write(0,'(A)') "--------------------------------------------------------------"
    call test_2
    if (.not. object_destroyed(21)) then
        success = .false.
        write(0,'(A)') "Object 21 was not destroyed"
    endif
    if (.not. object_destroyed(22)) then
        success = .false.
        write(0,'(A)') "Object 22 was not destroyed"
    endif
#endif

    write(0,'(A)') "--------------------------------------------------------------"

    if (.not. success) then
      stop 1
    endif

contains

subroutine test_1
    use atlas_object_module, only : Object

    type(Object) :: obj

    obj = Object(11)

    if( obj%owners() /= 1 ) then
        write(0,*) "ERROR: obj%owners /= 1"
        success = .false.
    endif

    write(0,'(A)') ""
    if (.not. autofinal) then
        write(0,'(A)') "autofinal=.false. --> manual finalisation"
        call obj%final()
    else
        write(0,'(A)') "autofinal=.false. --> automatic finalisation"
    endif


end subroutine

subroutine test_2
    use atlas_object_module, only : Object

    type(Object) :: obj1
    type(Object) :: obj2


    obj1 = Object(21)
    
    if( obj1%owners() /= 1 ) then
        write(0,'(A,I0)') "ERROR: obj1%owners /= 1    owners = ", obj1%owners()
        success = .false.
    endif

    obj2  = obj1%create_object(22) ! this registers obj1 inside obj2 --> obj1%owners() += 1

    if( obj1%owners() /= 2 ) then
        write(0,'(A,I0)') "ERROR: obj1%owners /= 2    owners = ", obj1%owners()
        success = .false.
    endif

    if( obj2%owners() /= 1 ) then
        write(0,'(A,I0)') "ERROR: obj2%owners /= 1    owners = ", obj2%owners()
        success = .false.
    endif

    write(0,'(A)') ""
    if (.not. autofinal) then
        write(0,'(A)') "autofinal=.false. --> manual finalisation"
        call obj2%final()
        if( obj1%owners() /= 1 ) then
            write(0,'(A,I0)') "ERROR: obj1%owners /= 1    owners = ", obj1%owners()
            success = .false.
        endif
        call obj1%final()
    else
        write(0,'(A)') "autofinal=.false. --> automatic finalisation"
    endif

end subroutine
end program
