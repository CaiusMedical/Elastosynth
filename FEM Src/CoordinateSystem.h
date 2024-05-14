//
// Created by mothership on 25/05/23.
//

#ifndef RECONSTRUCTION_FEM_CODE_COORDINATESYSTEM_H
#define RECONSTRUCTION_FEM_CODE_COORDINATESYSTEM_H


#include <string>

class CoordinateSystem {

public:
    std::string type;
    int axial_element_resolution;
    int axial_nodal_resolution;
    int lateral_element_resolution;
    int lateral_nodal_resolution;
    double start_location [2];
    double depth;
    double width;

    CoordinateSystem();
    CoordinateSystem(std::string type, int axial_nodal_resolution, int lateral_nodal_resolution, double axial_start = 0,
                     double lateral_start = 0, double depth = 50, double length = 50);

};


#endif //RECONSTRUCTION_FEM_CODE_COORDINATESYSTEM_H
