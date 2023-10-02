# Unload to be certain
module --force purge

# Load modules

module load prgenv/gnu
module load gcc/13.1
module load cmake/new
module list 

export CC=gcc
export CXX=g++
export FC=gfortran
