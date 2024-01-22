subroutine print_setup()
write(0,*) "--------------------------"
#ifdef NO_AUTOFINAL
  write(0,*) "AUTOFINAL=OFF"
#else
  write(0,*) "AUTOFINAL=ON"
#endif
#ifdef ALLOCATE_ZERO
  write(0,*) "ALLOCATE_ZERO=ON"
#else
  write(0,*) "ALLOCATE_ZERO=OFF"
#endif
#ifdef ASSIGN
  write(0,*) "ASSIGN=ON"
#else
  write(0,*) "ASSIGN=OFF"
#endif
#ifdef MANUAL_FINAL
  write(0,*) "MANUAL_FINAL=ON"
#else
  write(0,*) "MANUAL_FINAL=OFF"
#endif
write(0,*) "--------------------------"
end subroutine

subroutine test()
    use fckit_configuration_module, only : fckit_configuration, fckit_configurations_alive, deallocate_fckit_configuration
    implicit none
    integer :: j
    type(fckit_configuration), allocatable :: conf_array(:)
    type(fckit_configuration) :: conf

    write(0,*) "Initializing conf"
    conf = fckit_configuration()
    conf%id = "lhs"  ! For debugging output

#ifdef ALLOCATE_ZERO
    allocate(conf_array(0))
#endif

#ifdef ASSIGN
    write(0,*) "Initializing conf_array via conf%get_config_list()"
    call conf%get_config_list(3,conf_array);
    write(0,*) "Content of conf_array:"
    do j=1,size(conf_array)
        write(0,'(A,I0,A,A)') "   conf_array(",j,"): ", conf_array(j)%json()
    enddo
#endif

    ! finalise all

#ifdef MANUAL_FINAL
    write(0,*) "--------------------------"
    write(0,*) "Manual finalisation:"
    if (allocated(conf_array)) then
#if defined(NO_AUTOFINAL) || defined(WORKAROUND_INTEL)
        write(0,*) "+ call deallocate_fckit_configuration(conf_array)"
        call deallocate_fckit_configuration(conf_array)
#else
        write(0,*) "+ deallocate(conf_array)"
        deallocate(conf_array)
#endif
    endif
    write(0,*) "+ call conf%final()"
    call conf%final()
#endif
    

    ! Any output after this is due to debugging output from automatic finalisation.
#ifndef NO_AUTOFINAL
    write(0,*) "--------------------------"
    write(0,*) "Automatic finalisation:"
#endif
end subroutine

program main
use fckit_configuration_module, only : fckit_configurations_alive
implicit none
call print_setup
call test
    write(0,*) "--------------------------"
if (fckit_configurations_alive() > 0 ) then
  write(0,*) "TEST FAILED: Memory leak occured; fckit_configurations_alive() = ",fckit_configurations_alive()
  stop 1
endif
if (fckit_configurations_alive() == 0 ) then
  write(0,*) "TEST PASSED"
else
  write(0,*) "TEST FAILED"
endif
end program
