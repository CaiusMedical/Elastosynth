cmake_minimum_required(VERSION 3.25)
project(Reconstruction_FEM_Code)

set(CMAKE_CXX_STANDARD 17)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/Armadillo_Include)
add_library(Reconstruction_Library STATIC CoordinateSystem.cpp CoordinateSystem.h FiniteElementModel.cpp FiniteElementModel.h FiniteElementResult.cpp FiniteElementResult.h Mesh.cpp Mesh.h Elements.cpp Elements.h BoundaryCondition.cpp BoundaryCondition.h Material.cpp Material.h MeshGenerator.cpp MeshGenerator.h FEM_Interface.h FEM_Interface.cpp MatrixGeneration.h MatrixGeneration.cpp)

IF (WIN32)
    target_link_libraries(Reconstruction_Library PUBLIC ${ARMADILLO_LIBRARIES} ${CMAKE_CURRENT_SOURCE_DIR}/Windows_Dependencies/SuperLu.lib ${CMAKE_CURRENT_SOURCE_DIR}/Windows_Dependencies/openblas.lib)
ELSE()
    target_link_libraries(Reconstruction_Library PUBLIC ${ARMADILLO_LIBRARIES} ${CMAKE_CURRENT_SOURCE_DIR}/Linux_Dependencies/libopenblas.so)
ENDIF()
