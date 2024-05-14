//
// Created by mothership on 25/05/23.
//

#include "FiniteElementResult.h"
#include "CoordinateSystem.h"
#include "Elements.h"

FiniteElementResult::FiniteElementResult() {}


FiniteElementResult::FiniteElementResult(CoordinateSystem* coordinate_system) {
    this->axial_displacements = arma::mat(coordinate_system->axial_nodal_resolution, coordinate_system->lateral_nodal_resolution);
    this->lateral_displacements = arma::mat(coordinate_system->axial_nodal_resolution, coordinate_system->lateral_nodal_resolution);
    this->axial_strain = arma::mat(coordinate_system->axial_element_resolution, coordinate_system->lateral_element_resolution);
    this->lateral_strain = arma::mat(coordinate_system->axial_element_resolution, coordinate_system->lateral_element_resolution);
    this->shear_strain = arma::mat(coordinate_system->axial_element_resolution, coordinate_system->lateral_element_resolution);
    this->axial_stresses = arma::mat(coordinate_system->axial_element_resolution, coordinate_system->lateral_element_resolution);
    this->lateral_stresses = arma::mat(coordinate_system->axial_element_resolution, coordinate_system->lateral_element_resolution);
}

void FiniteElementResult::PopulateFromNodalDisplacements(arma::mat nodal_displacement_matrix, Material* material, Element* element) {

    arma::mat::iterator nodal_displacement_iterator = nodal_displacement_matrix.begin();
    arma::mat::iterator axial_displacement_iterator = this->axial_displacements.begin();
    arma::mat::iterator lateral_displacement_iterator = this->lateral_displacements.begin();

    for(; nodal_displacement_iterator < nodal_displacement_matrix.end();++nodal_displacement_iterator){

        //Extract the axial
        *axial_displacement_iterator = *nodal_displacement_iterator;
        //Increment iterator
        nodal_displacement_iterator++;

        //Extract the lateral
        *lateral_displacement_iterator = *nodal_displacement_iterator;

        //increment both
        axial_displacement_iterator++;
        lateral_displacement_iterator++;

    }

    CalculateStrains();
    std::cout<<"Strains Calculated\n";
    CalculateStresses(material, element);
    std::cout<<"Stresses Calculated\n";

}

void FiniteElementResult::CalculateStrains() {

    arma::mat axial_strain = arma::diff(this->axial_displacements, 1, 0);
    this->axial_strain = axial_strain.submat(0,0,axial_strain.n_rows-1, axial_strain.n_cols-2);
    arma::mat lateral_strain = arma::diff(this->lateral_displacements, 1, 1);
    this->lateral_strain = lateral_strain.submat(0,0,lateral_strain.n_rows-2, lateral_strain.n_cols-1);

    arma::mat axial_d_lateral = arma::diff(this->axial_displacements, 1, 1);
    arma::mat lateral_d_axial = arma::diff(this->lateral_displacements, 1, 0);
    this->shear_strain = 0.5 * (lateral_d_axial.submat(0,0,axial_strain.n_rows-1, axial_strain.n_cols-2)
            + axial_d_lateral.submat(0,0,lateral_strain.n_rows-2, lateral_strain.n_cols-1));

}

void FiniteElementResult::CalculateStresses(Material* material, Element* element) {

    arma::mat coeff = material->youngs_modulus / ((1+material->poissons_ratio)%(1-2*material->poissons_ratio));

    arma::cube out_of_plane = element->GetOutOfPlane(material, &this->axial_strain, &this->lateral_strain, &this->axial_stresses, &this->lateral_stresses);

    this->axial_stresses = coeff % ((1-material->poissons_ratio)%this->axial_strain
                                    + material->poissons_ratio%(this->lateral_strain + out_of_plane.slice(0)));

    this->lateral_stresses = coeff % ((1-material->poissons_ratio)%this->lateral_strain
                                      + material->poissons_ratio%(this->axial_strain + out_of_plane.slice(0)));

    this->shear_stresses = (material->youngs_modulus / (2 + 2*material->poissons_ratio)) % this->shear_strain;

}