# Unload to be certain
module --force purge

# Load modules
module load LUMI/23.03
module load partition/C
module load cpeCray/23.03
module load buildtools/23.03


module unload cray-mpich
module unload cray-libsci

module list 

export CC=cc
export CXX=CC
export FC=ftn
