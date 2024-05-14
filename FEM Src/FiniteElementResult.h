//
// Created by mothership on 25/05/23.
//

#ifndef RECONSTRUCTION_FEM_CODE_FINITEELEMENTRESULT_H
#define RECONSTRUCTION_FEM_CODE_FINITEELEMENTRESULT_H


#include <armadillo>
#include "CoordinateSystem.h"
#include "Material.h"
#include "Elements.h"

class FiniteElementResult {
public:
    arma::mat axial_displacements;
    arma::mat lateral_displacements;
    arma::mat axial_strain;
    arma::mat lateral_strain;
    arma::mat shear_strain;
    arma::mat axial_stresses;
    arma::mat lateral_stresses;
    arma::mat shear_stresses;

    FiniteElementResult();
    FiniteElementResult(CoordinateSystem* coordinate_system);
    void PopulateFromNodalDisplacements(arma::mat displacement_matrix, Material* material, Element* element);
    void UpdateMaterial(Material* material, std::string reconstruction_type, Element* element, double weight_ratio, int* window_sizes);

private:
    void CalculateStrains();
    void CalculateStresses(Material* material, Element* element);
};


#endif //RECONSTRUCTION_FEM_CODE_FINITEELEMENTRESULT_H
