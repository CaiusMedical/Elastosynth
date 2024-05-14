//
// Created by mothership on 25/05/23.
//

#ifndef RECONSTRUCTION_FEM_CODE_BOUNDARYCONDITIONS_H
#define RECONSTRUCTION_FEM_CODE_BOUNDARYCONDITIONS_H
#include <iostream>
#include <armadillo>
#include "CoordinateSystem.h"


class BoundaryCondition {

public:
    std::string boundary_type;
    arma::umat nodes_labels;
    arma::mat values;

    BoundaryCondition();
    BoundaryCondition(std::string boundary_type, arma::mat values, std::string location,
                      CoordinateSystem* coordinate_system);

};


#endif //RECONSTRUCTION_FEM_CODE_BOUNDARYCONDITIONS_H
