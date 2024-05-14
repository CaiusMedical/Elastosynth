//
// Created by mothership on 25/05/23.
//

#include "Material.h"

Material::Material(){

}

Material::Material(arma::mat youngs_modulus, arma::mat poissons_ratio) {
    this->youngs_modulus = youngs_modulus;
    this->poissons_ratio = poissons_ratio;
}

Material::Material(Material_MATLAB material, std::vector<int> material_dimensions) {
    arma::mat youngs_modulus_ARMA = arma::conv_to<arma::mat>::from(material.youngs_modulus);
    arma::mat poissons_ratio_ARMA = arma::conv_to<arma::mat>::from(material.poissons_ratio);
    youngs_modulus_ARMA.reshape(material_dimensions[0], material_dimensions[1]);
    poissons_ratio_ARMA.reshape(material_dimensions[0], material_dimensions[1]);
    this->youngs_modulus = youngs_modulus_ARMA;
    this->poissons_ratio = poissons_ratio_ARMA;
}

void Material::set_youngs_modulus(arma::mat youngs_modulus) {
    this->youngs_modulus = youngs_modulus;
}

void Material::set_poissons_ratio(arma::mat poissons_ratio) {
    this->poissons_ratio = poissons_ratio;
}
