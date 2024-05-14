//
// Created by mothership on 25/05/23.
//

#include <iostream>
#include "FiniteElementModel.h"
#include "Material.h"
#include "MeshGenerator.h"
#include "MatrixGeneration.h"

FiniteElementModel::FiniteElementModel() {}

FiniteElementModel::FiniteElementModel(Element* element, CoordinateSystem* coordinate_system,
                                       std::vector<BoundaryCondition> boundary_conditions, Material* material,
                                       bool stability_controls, bool use_GPU, int number_of_cpus) {
    this->element = element;
    this->coordinate_system = coordinate_system;
    this->boundary_conditions = boundary_conditions;
    this->material = material;
    this->stability_controls = stability_controls;
    this->use_GPU = use_GPU;
    this->number_of_cpus = number_of_cpus;
    this->result = FiniteElementResult(coordinate_system);
    this->old_material = Material(material->youngs_modulus, material->poissons_ratio);

    // Generate the mesh
    this->mesh = MeshGenerator::GenerateMesh(coordinate_system, element);

    // This is where the matrices are formed and initialized
    this->global_stiffness_matrix = arma::sp_mat(this->mesh.total_nodes * this->mesh.degrees_of_freedom,
                                               this->mesh.total_nodes * this->mesh.degrees_of_freedom);
    this->nodal_displacement_matrix = arma::mat(this->mesh.total_nodes * this->mesh.degrees_of_freedom, 1);
    this->nodal_force_matrix = arma::mat(this->mesh.total_nodes * this->mesh.degrees_of_freedom, 1);

    std::cout << "Matrices Partitioned\n";

    arma::umat displacement_node_labels = arma::umat(0,1, arma::fill::zeros);
    arma::umat force_node_labels = arma::umat(0,1, arma::fill::zeros);

    arma::mat displacement_node_values = arma::mat(0,2,arma::fill::zeros);
    arma::mat force_node_values = arma::mat(0,2,arma::fill::zeros);

    for(BoundaryCondition boundary_condition : boundary_conditions){
        if (boundary_condition.boundary_type == "displacement"){
            displacement_node_labels = arma::join_cols(displacement_node_labels, boundary_condition.nodes_labels);
            displacement_node_values = arma::join_cols(displacement_node_values, boundary_condition.values);
        }else{
            displacement_node_labels = arma::join_cols(displacement_node_labels, boundary_condition.nodes_labels);
            displacement_node_values = arma::join_cols(displacement_node_values, boundary_condition.values);
        }
    }

    PopulateGlobalStiffnessMatrix(&this->global_stiffness_matrix, &this->mesh, this->material, &displacement_node_labels, &force_node_labels,
                                  0, this->mesh.elements.n_rows-1);

    std::cout << "Matrices Formed\n";

    AssignBoundaryConditions(&this->global_stiffness_matrix, &this->nodal_force_matrix, displacement_node_labels, displacement_node_values,
                             force_node_labels, force_node_values);

    std::cout << "Boundary Conditions Imposed\n";

}

void FiniteElementModel::RunModel() {

    this->result.PopulateFromNodalDisplacements(arma::spsolve(this->global_stiffness_matrix, this->nodal_force_matrix),
                                                this->material, this->element);

}

void FiniteElementModel::PrintContents(){
    std::cout << "\n" << this->element->name;
    std::cout << "\n" << "stability controls: " << this->stability_controls;
    std::cout << "\n" << "useGPU: " << this->stability_controls;
    std::cout << "\n" << "number_of_cpus: " << this->stability_controls;
}

FiniteElementResult FiniteElementModel::GetFiniteElementResult(){
    return this->result;
}