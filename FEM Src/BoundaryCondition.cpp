//
// Created by mothership on 25/05/23.
//

#include "BoundaryCondition.h"
#include "MeshGenerator.h"

BoundaryCondition::BoundaryCondition(std::string boundary_type, arma::mat values, std::string location,
                                     CoordinateSystem *coordinate_system) {
    this->boundary_type = boundary_type;
    this->nodes_labels = arma::conv_to<arma::umat>::from(MeshGenerator::GetNodes(coordinate_system, location).col(0));
    this->values = values;
}