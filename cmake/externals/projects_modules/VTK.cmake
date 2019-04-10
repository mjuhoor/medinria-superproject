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
  ffmpeg
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

set(tag tags/v5.10.1)
if (NOT DEFINED ${ep}_SOURCE_DIR)
    set(location GIT_REPOSITORY "${GITHUB_PREFIX}Kitware/VTK.git" GIT_TAG ${tag})
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

# library extension
if (UNIX AND NOT APPLE)
   set(extention so)
elseif(APPLE)
   set(extention dylib)
elseif (WIN32)
   set(extention lib)
endif()

set(cmake_args_generic
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
  # OGV
  -DVTK_USE_OGGTHEORA_ENCODER:BOOL=ON
  # To be removed when upgrading VTK version
  -DVTK_REQUIRED_OBJCXX_FLAGS:STRING=""
  )

if (WIN32)
set(cmake_args
  ${cmake_args_generic}
   # MPEG2
  -DVTK_USE_MPEG2_ENCODER:BOOL=ON
  -DvtkMPEG2Encode_INCLUDE_PATH:STRINGS=${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg$<SEMICOLON>${CMAKE_CURRENT_SOURCE_DIR}/build/ffmpeg/build
  -DvtkMPEG2Encode_LIBRARIES:STRING=${CMAKE_CURRENT_SOURCE_DIR}/build/ffmpeg/build/${CMAKE_BUILD_TYPE}/vtkMPEG2Encode.${extention}
  )
else()
set(cmake_args
  ${cmake_args_generic}
  # FFMPEG
  -DVTK_USE_FFMPEG_ENCODER:BOOL=ON
  -DFFMPEG_INCLUDE_DIR:STRING=${CMAKE_CURRENT_SOURCE_DIR}/build/ffmpeg/build/include/
  -DFFMPEG_avcodec_LIBRARY:STRING=${CMAKE_CURRENT_SOURCE_DIR}/build/ffmpeg/build/lib/libavcodec.${extention}
  -DFFMPEG_avformat_LIBRARY:STRING=${CMAKE_CURRENT_SOURCE_DIR}/build/ffmpeg/build/lib/libavformat.${extention}
  -DFFMPEG_avutil_LIBRARY:STRING=${CMAKE_CURRENT_SOURCE_DIR}/build/ffmpeg/build/lib/libavutil.${extention}
  -DFFMPEG_swscale_LIBRARY:STRING=${CMAKE_CURRENT_SOURCE_DIR}/build/ffmpeg/build/lib/libswscale.${extention}
  )
endif()
  
## #############################################################################
## Check if patch has to be applied
## #############################################################################

ep_GeneratePatchCommand(VTK VTK_PATCH_COMMAND vtk5.10.1VS2015.patch)

## #############################################################################
## Add external-project
## #############################################################################

ExternalProject_Add(${ep}
  ${ep_dirs}
  ${location}
  UPDATE_COMMAND ""
  PATCH_COMMAND ${VTK_PATCH_COMMAND}
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
