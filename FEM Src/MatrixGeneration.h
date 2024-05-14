//
// Created by matt on 07/06/23.
//

#ifndef RECONSTRUCTION_FEM_CODE_MATRIXGENERATION_H
#define RECONSTRUCTION_FEM_CODE_MATRIXGENERATION_H

#include <armadillo>
#include "Elements.h"
#include "Mesh.h"
#include "BoundaryCondition.h"

void PopulateGlobalStiffnessMatrix(arma::sp_mat* global_stiffness_matrix, Mesh* mesh, Material* material, arma::umat* displacement_node_labels,
                                   arma::umat* force_node_labels, int start_element, int step);

void ConstructElementStiffnessMatrix(arma::mat* element_stiffness_matrix, Element* element, arma::mat node_points, arma::umat node_indices,
                                     arma::mat* B_Matrix, arma::mat* J_matrix, arma::mat* gauss_quadrature,
                                     arma::mat* local_shape_gradient, arma::mat* global_shape_gradient, arma::mat* material_tangent,
                                     double youngs_modulus, double poissons_ratio);

void UpdateGlobalStiffnessMatrixMultiThreaded(arma::sp_mat* global_stiffness_matrix, Mesh* mesh, Material* material,
                                                arma::umat* displacement_node_labels, arma::umat* force_node_labels, int number_of_cpus);

void AssignBoundaryConditions(arma::sp_mat* global_stiffness_matrix, arma::mat* nodal_force_matrix,
                              arma::umat displacement_node_labels, arma::mat displacement_node_values,
                              arma::umat force_node_labels, arma::mat force_node_values);

#endif //RECONSTRUCTION_FEM_CODE_MATRIXGENERATION_H
