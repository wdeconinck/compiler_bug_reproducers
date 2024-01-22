# Unload to be certain
module --force purge

# Load modules

module load prgenv/nvidia
module load nvidia/22.11
module load cmake/new
module list 

export CC=nvc
export CXX=nvc++
export FC=nvfortran
