# Source me to get the correct configure/build/run environment

module_load() {
  echo "+ module load $1"
  module load $1
}

# Unload to be certain
module --force purge

# Load modules
module_load CrayEnv
module_load PrgEnv-cray/8.4.0
module_load cce/16.0.1
module_load craype-accel-amd-gfx90a
module_load buildtools/23.09

export CC=cc
export CXX=CC
export FC=ftn

module list 2>&1

