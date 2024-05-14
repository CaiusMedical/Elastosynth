//
// Created by mothership on 25/05/23.
//

#ifndef RECONSTRUCTION_FEM_CODE_ELEMENTS_H
#define RECONSTRUCTION_FEM_CODE_ELEMENTS_H


#include <string>
#include <armadillo>
#include "Material.h"

class Element {
public:
    std::string name;
    int no_nodes;

    virtual void ShapeFunction(arma::mat* shape_functions, arma::mat local_coordinates);
    virtual void ShapeFunctionGradient(arma::mat* shape_functions, arma::mat local_coordinates);
    virtual void GenerateMaterialTangent(arma::mat* material_tangent, double youngs_modulus, double poissons_ratio);
    virtual arma::cube GetOutOfPlane(Material* material, arma::mat* axial_strain, arma::mat* lateral_strain,
                                     arma::mat* axial_stress, arma::mat* lateral_stress);
};

class LinearPlaneStrainElement: virtual public Element{
public:

    LinearPlaneStrainElement();
    void ShapeFunction(arma::mat* shape_functions, arma::mat local_coordinates);
    void ShapeFunctionGradient(arma::mat* shape_functions, arma::mat local_coordinates);
    void GenerateMaterialTangent(arma::mat* material_tangent, double youngs_modulus, double poissons_ratio);
    arma::cube GetOutOfPlane(Material* material, arma::mat* axial_strain, arma::mat* lateral_strain,
                             arma::mat* axial_stress, arma::mat* lateral_stress);
};

class LinearPlaneStressElement: virtual public Element{
public:
    LinearPlaneStressElement();

    void ShapeFunction(arma::mat* shape_functions, arma::mat local_coordinates);
    void ShapeFunctionGradient(arma::mat* shape_functions, arma::mat local_coordinates);
    void GenerateMaterialTangent(arma::mat* material_tangent, double youngs_modulus, double poissons_ratio);
    arma::cube GetOutOfPlane(Material* material, arma::mat* axial_strain, arma::mat* lateral_strain,
                             arma::mat* axial_stress, arma::mat* lateral_stress);
};


#endif //RECONSTRUCTION_FEM_CODE_ELEMENTS_H
