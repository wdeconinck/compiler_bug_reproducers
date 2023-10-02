# Unload to be certain
module --force purge

# Load modules
module load LUMI/22.08
module load partition/C
module load cpeCray/22.08
module load buildtools/22.08


module unload cray-mpich
module unload cray-libsci

module list 

export CC=cc
export CXX=CC
export FC=ftn
