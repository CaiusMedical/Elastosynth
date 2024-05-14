//
// Created by mothership on 25/05/23.
//

#include "Elements.h"

// Define some bullshit for base class to avoid errors from pure virtual functions

void Element::ShapeFunction(arma::mat* shape_functions, arma::mat local_coordinates){}

void Element::ShapeFunctionGradient(arma::mat* shape_function_gradients, arma::mat local_coordinates){}

void Element::GenerateMaterialTangent(arma::mat* material_tangent, double youngs_modulus, double poissons_ratio){}

arma::cube Element::GetOutOfPlane(Material* material, arma::mat *axial_strain,
                                 arma::mat *lateral_strain, arma::mat* axial_stress, arma::mat* lateral_stress)
                                 {return arma::cube(1,1,1);}

// Linear Plane Strain Element Definition - Overload the relevant functions

LinearPlaneStrainElement::LinearPlaneStrainElement(){
    this->name = "PStrain";
    this->no_nodes = 4;
}

void LinearPlaneStrainElement::ShapeFunction(arma::mat* shape_functions, arma::mat local_coordinates) {

    *shape_functions ={(1 - local_coordinates[0]) * (1 - local_coordinates[1]),
                      (1+local_coordinates[0]) * (1-local_coordinates[1]),
                      (1+local_coordinates[0]) * (1+local_coordinates[1]),
                      (1-local_coordinates[0]) * (1+local_coordinates[1])};

    *shape_functions = *shape_functions * 0.25;

}

void LinearPlaneStrainElement::ShapeFunctionGradient(arma::mat* shape_function_gradients, arma::mat local_coordinates) {


    shape_function_gradients->col(0) = {-(1 - local_coordinates[1]), -(1 - local_coordinates[0])};
    shape_function_gradients->col(1) = {(1 - local_coordinates[1]), -(1 + local_coordinates[0])};
    shape_function_gradients->col(2) = {(1 + local_coordinates[1]), (1 + local_coordinates[0])};
    shape_function_gradients->col(3) = {-(1 + local_coordinates[1]), (1 - local_coordinates[0])};

    *shape_function_gradients = *shape_function_gradients * 0.25;
}

void LinearPlaneStrainElement::GenerateMaterialTangent(arma::mat* material_tangent, double youngs_modulus, double poissons_ratio) {

    float coefficient = youngs_modulus/(1+poissons_ratio)/(1-2*poissons_ratio);

    material_tangent->col(0) = {1-poissons_ratio, poissons_ratio, 0};
    material_tangent->col(1) = {poissons_ratio, 1-poissons_ratio, 0};
    material_tangent->col(2) = {0, 0, 0.5-poissons_ratio};
    *material_tangent = *material_tangent * coefficient;

}

arma::cube LinearPlaneStrainElement::GetOutOfPlane(Material* material, arma::mat* axial_strain, arma::mat* lateral_strain,
                                                   arma::mat* axial_stress, arma::mat* lateral_stress) {

    arma::cube out_of_plane = arma::cube(axial_strain->n_rows, axial_strain->n_cols, 2);

    // No strain because its zero

    out_of_plane.slice(1) = material->poissons_ratio % (*axial_stress + *lateral_stress);

    return out_of_plane;

}

// Linear Plane Stress Element

LinearPlaneStressElement::LinearPlaneStressElement(){
    this->name = "PStress";
    this->no_nodes = 4;
}

void LinearPlaneStressElement::ShapeFunction(arma::mat* shape_functions, arma::mat local_coordinates) {

    *shape_functions ={(1 - local_coordinates[0]) * (1 - local_coordinates[1]),
                       (1+local_coordinates[0]) * (1-local_coordinates[1]),
                       (1+local_coordinates[0]) * (1+local_coordinates[1]),
                       (1-local_coordinates[0]) * (1+local_coordinates[1])};

    *shape_functions = *shape_functions * 0.25;

}

void LinearPlaneStressElement::ShapeFunctionGradient(arma::mat* shape_function_gradients, arma::mat local_coordinates) {


    shape_function_gradients->col(0) = {-(1 - local_coordinates[1]), -(1 - local_coordinates[0])};
    shape_function_gradients->col(1) = {(1 - local_coordinates[1]), -(1 + local_coordinates[0])};
    shape_function_gradients->col(2) = {(1 + local_coordinates[1]), (1 + local_coordinates[0])};
    shape_function_gradients->col(3) = {-(1 + local_coordinates[1]), (1 - local_coordinates[0])};

    *shape_function_gradients = *shape_function_gradients * 0.25;
}

void LinearPlaneStressElement::GenerateMaterialTangent(arma::mat* material_tangent, double youngs_modulus, double poissons_ratio) {

    float coefficient = youngs_modulus/(1-poissons_ratio*poissons_ratio);

    material_tangent->col(0) = {1, poissons_ratio, 0};
    material_tangent->col(1) = {poissons_ratio, 1, 0};
    material_tangent->col(2) = {0, 0, 0.5-0.5*poissons_ratio};
    *material_tangent = *material_tangent * coefficient;

}

arma::cube LinearPlaneStressElement::GetOutOfPlane(Material* material, arma::mat* axial_strain, arma::mat* lateral_strain,
                                                   arma::mat* axial_stress, arma::mat* lateral_stress) {

    arma::cube out_of_plane = arma::cube(axial_strain->n_rows, axial_strain->n_cols, 2);

    arma::mat A_coeff = material->youngs_modulus / (1 - material->poissons_ratio % material->poissons_ratio);
    arma::mat B_coeff = material->youngs_modulus / ((1+material->poissons_ratio)%(1-2*material->poissons_ratio));

    out_of_plane.slice(0) = ((A_coeff - B_coeff + B_coeff%material->poissons_ratio) % *axial_strain
            + material->poissons_ratio%(A_coeff-B_coeff)%*lateral_strain)/(B_coeff%material->poissons_ratio);

    // No stress because its zero

    return out_of_plane;

}
