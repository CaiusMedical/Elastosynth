//
// Created by mothership on 25/05/23.
//

#include "Mesh.h"

Mesh::Mesh(CoordinateSystem *coordinate_system, Element* element) {

    this->element = element;
    this->total_nodes = (coordinate_system->axial_nodal_resolution)*(coordinate_system->lateral_nodal_resolution);
    this->degrees_of_freedom = 2;

    this->nodes = arma::mat(this->total_nodes,
                           3, arma::fill::zeros);


    this->elements = arma::umat(coordinate_system->axial_element_resolution*coordinate_system->lateral_element_resolution,
                                element->no_nodes, arma::fill::zeros);
}

Mesh::Mesh() {};