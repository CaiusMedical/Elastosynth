//
// Created by mothership on 30/05/23.
//

#ifndef RECONSTRUCTION_FEM_CODE_MESHGENERATOR_H
#define RECONSTRUCTION_FEM_CODE_MESHGENERATOR_H

#include <armadillo>
#include "CoordinateSystem.h"
#include "Mesh.h"


class MeshGenerator {

public:
    static arma::mat GetNodes(CoordinateSystem* coordinate_system, std::string location);
    static Mesh GenerateMesh(CoordinateSystem* coordinate_system, Element* element);

private:
    static int MapLocations(std::string const& location);
};


#endif //RECONSTRUCTION_FEM_CODE_MESHGENERATOR_H
