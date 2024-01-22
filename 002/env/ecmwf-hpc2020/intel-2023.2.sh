# Unload to be certain
module --force purge

# Load modules

module load prgenv/intel
module load intel/2023.2
module load cmake/new
module list 

export CC=icc
export CXX=icpc
export FC=ifort
