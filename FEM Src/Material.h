//
// Created by mothership on 25/05/23.
//

#ifndef RECONSTRUCTION_FEM_CODE_MATERIAL_H
#define RECONSTRUCTION_FEM_CODE_MATERIAL_H


#include <armadillo>
#include "FEM_Interface.h"

class Material {

public:
    arma::mat youngs_modulus;
    arma::mat poissons_ratio;

    Material();
    Material(arma::mat youngs_modulus, arma::mat poissons_ratio);
    Material(Material_MATLAB material, std::vector<int> material_dimensions);

    void set_youngs_modulus(arma::mat youngs_modulus);
    void set_poissons_ratio(arma::mat poissons_ratio);

};


#endif //RECONSTRUCTION_FEM_CODE_MATERIAL_H
