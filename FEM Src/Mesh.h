//
// Created by mothership on 25/05/23.
//

#ifndef RECONSTRUCTION_FEM_CODE_MESH_H
#define RECONSTRUCTION_FEM_CODE_MESH_H


#include <armadillo>
#include "CoordinateSystem.h"
#include "Elements.h"

class Mesh {

public:
    int total_nodes;
    int degrees_of_freedom;
    Element* element;
    arma::mat nodes;
    arma::umat elements;

    Mesh();
    Mesh(CoordinateSystem* coordinate_system, Element* element);
};


#endif //RECONSTRUCTION_FEM_CODE_MESH_H
