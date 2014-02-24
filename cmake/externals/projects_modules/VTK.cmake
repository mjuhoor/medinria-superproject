################################################################################
#
# medInria
#
# Copyright (c) INRIA 2013. All rights reserved.
# See LICENSE.txt for details.
# 
#  This software is distributed WITHOUT ANY WARRANTY; without even
#  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#  PURPOSE.
#
################################################################################

function(VTK_project)
set(ep VTK)


## #############################################################################
## List the dependencies of the project
## #############################################################################

list(APPEND ${ep}_dependencies 
  Qt4
  )
  

## #############################################################################
## Prepare the project
## #############################################################################

EP_Initialisation(${ep} 
  USE_SYSTEM OFF 
  BUILD_SHARED_LIBS ON
  REQUIRED_FOR_PLUGINS ON
  )


if (NOT USE_SYSTEM_${ep})
## #############################################################################
## Set directories
## #############################################################################

EP_SetDirectories(${ep}
  EP_DIRECTORIES ep_dirs
  )


## #############################################################################
## Define repository where get the sources
## #############################################################################

if (NOT DEFINED ${ep}_SOURCE_DIR)
    set(location GIT_REPOSITORY "git://vtk.org/VTK.git")
    # Set GIT_TAG to latest commit of origin/release-5.10 known to work
    set(tag GIT_TAG d3b66526624ba8e55addcddb0ec28c40982473ac)
endif()


## #############################################################################
## Add specific cmake arguments for configuration step of the project
## #############################################################################

# set compilation flags
if (UNIX)
  set(${ep}_c_flags "${${ep}_c_flags} -w")
  set(${ep}_cxx_flags "${${ep}_cxx_flags} -w")
  set(unix_additional_args -DVTK_USE_NVCONTROL:BOOL=ON)
endif()

set(cmake_args
  ${ep_common_cache_args}
  -DCMAKE_C_FLAGS:STRING=${${ep}_c_flags}
  -DCMAKE_CXX_FLAGS:STRING=${${ep}_cxx_flags}
  -DCMAKE_SHARED_LINKER_FLAGS:STRING=${${ep}_shared_linker_flags}  
  -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>  
  -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS_${ep}}
  -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
  -DVTK_USE_QT:BOOL=ON
  -DVTK_WRAP_TCL:BOOL=OFF
  -DBUILD_TESTING:BOOL=OFF 
  )

## #############################################################################
## Check if patch has to be applied
## #############################################################################

set(VTK_PATCHES VTK_WindowLevel.patch)
set(VTK_PATCHES_TO_APPLY)
foreach (patch ${VTK_PATCHES})
    execute_process(COMMAND git apply --check ${CMAKE_SOURCE_DIR}/patches/${patch}
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/VTK
                    RESULT_VARIABLE   PATCH_OK
                    OUTPUT_QUIET
                    ERROR_QUIET)
    if (PATCH_OK EQUAL 0)
        set(VTK_PATCHES_TO_APPLY ${VTK_PATCHES_TO_APPLY} ${CMAKE_SOURCE_DIR}/patches/${patch})
    endif()
endforeach()

set(VTK_PATCH_COMMAND)
if (NOT "${VTK_PATCHES_TO_APPLY}" STREQUAL "")
    set(VTK_PATCH_COMMAND git apply ${VTK_PATCHES_TO_APPLY})
endif()

## #############################################################################
## Add external-project
## #############################################################################

ExternalProject_Add(${ep}
  ${ep_dirs}
  ${location}
  ${tag}
  UPDATE_COMMAND ""
  ${VTK_PATCH_COMMAND}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS ${cmake_args}
  DEPENDS ${${ep}_dependencies}
  INSTALL_COMMAND ""
  )
  

## #############################################################################
## Set variable to provide infos about the project
## #############################################################################

ExternalProject_Get_Property(${ep} binary_dir)
set(${ep}_DIR ${binary_dir} PARENT_SCOPE)


## #############################################################################
## Add custom targets
## #############################################################################

EP_AddCustomTargets(${ep})


endif() #NOT USE_SYSTEM_ep

endfunction()
