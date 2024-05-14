//
// Created by mothership on 25/05/23.
//

#ifndef RECONSTRUCTION_FEM_CODE_FINITEELEMENTMODEL_H
#define RECONSTRUCTION_FEM_CODE_FINITEELEMENTMODEL_H


#include "Mesh.h"
#include "CoordinateSystem.h"
#include "Elements.h"
#include "BoundaryCondition.h"
#include "FiniteElementResult.h"
#include "Material.h"

class FiniteElementModel {
private:
    Mesh mesh;
    Element* element;
    CoordinateSystem* coordinate_system;
    arma::mat nodal_displacement_matrix;
    arma::sp_mat global_stiffness_matrix;
    arma::mat nodal_force_matrix;
    std::vector<BoundaryCondition> boundary_conditions;
    bool stability_controls;
    int number_of_cpus;
    bool use_GPU;
    FiniteElementResult result;
    Material old_material;
    Material* material;

public:
    FiniteElementModel();
    FiniteElementModel(Element* element, CoordinateSystem* coordinate_system, std::vector<BoundaryCondition> boundary_conditions,
                       Material* material, bool stability_controls = true, bool use_GPU = false, int number_of_cpus = 1);
    FiniteElementResult GetFiniteElementResult();
    void UpdateModel(std::string reconstruction_type, double weight_ratio, int* window_sizes);
    bool CheckConvergence(double tolerance);
    void RunModel();
    void PrintContents();
};


#endif //RECONSTRUCTION_FEM_CODE_FINITEELEMENTMODEL_H
