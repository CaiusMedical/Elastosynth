//
// Created by mothership on 25/05/23.
//

#include "CoordinateSystem.h"

CoordinateSystem::CoordinateSystem() {

    this->type = "cartesian";
    this->axial_nodal_resolution = 4;
    this->lateral_nodal_resolution = 4;
    this->axial_element_resolution = this->axial_nodal_resolution - 1;
    this->lateral_element_resolution = this->lateral_nodal_resolution - 1;
    this->depth = 50;
    this->width = 50;
    this->start_location[0] = 0;
    this->start_location[1] = 0;
}

CoordinateSystem::CoordinateSystem(std::string type, int axial_nodal_resolution, int lateral_nodal_resolution, double axial_start,
                                   double lateral_start, double depth, double width) {

    this->type = type;
    this->axial_nodal_resolution = axial_nodal_resolution;
    this->lateral_nodal_resolution = lateral_nodal_resolution;
    this->axial_element_resolution = this->axial_nodal_resolution - 1;
    this->lateral_element_resolution = this->lateral_nodal_resolution - 1;
    this->start_location[0] = axial_start;
    this->start_location[1] = lateral_start;
    this->depth = depth;
    this->width = width;

}