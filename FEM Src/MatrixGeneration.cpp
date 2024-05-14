//
// Created by matt on 07/06/23.
//

#include <armadillo>
#include "Elements.h"
#include "Mesh.h"
#include "Material.h"
#include <math.h>
#include <thread>
#include "BoundaryCondition.h"

void ConstructElementStiffnessMatrix(arma::mat* element_stiffness_matrix, Element* element, arma::mat node_points,
                                     arma::mat* B_matrix, arma::mat* J_matrix, arma::mat* gauss_quadrature,
                                     arma::mat* local_shape_gradient, arma::mat* global_shape_gradient, arma::mat* material_tangent,
                                     double youngs_modulus, double poissons_ratio){
    element_stiffness_matrix->fill(0);


    for(int i = 0; i < element->no_nodes; i++){
        arma::mat q = gauss_quadrature->row(i);

        element->ShapeFunctionGradient(local_shape_gradient, q);
        *J_matrix = *local_shape_gradient * node_points; // node points is 4x2
        *global_shape_gradient = arma::inv(*J_matrix) * *local_shape_gradient; //Double transpose is just a hack to get it working, I have no idea why

        B_matrix->row(0) = {global_shape_gradient->row(0)[0], 0,
                            global_shape_gradient->row(0)[1], 0,
                            global_shape_gradient->row(0)[2], 0,
                            global_shape_gradient->row(0)[3], 0};

        B_matrix->row(1) ={0, global_shape_gradient->row(1)[0],
                           0, global_shape_gradient->row(1)[1],
                           0, global_shape_gradient->row(1)[2],
                           0, global_shape_gradient->row(1)[3],};

        B_matrix->row(2) = {global_shape_gradient->row(1)[0], global_shape_gradient->row(0)[0],
                           global_shape_gradient->row(1)[1], global_shape_gradient->row(0)[1],
                           global_shape_gradient->row(1)[2], global_shape_gradient->row(0)[2],
                           global_shape_gradient->row(1)[3], global_shape_gradient->row(0)[3]};

        element->GenerateMaterialTangent(material_tangent, youngs_modulus, poissons_ratio);

        //std::cout<< "\n" << i << "\n" << node_points << "\n" << *J_matrix << "\n";

        *element_stiffness_matrix = *element_stiffness_matrix + B_matrix->t() * *material_tangent
                                                               * *B_matrix * arma::det(*J_matrix);


    }
}

void PopulateGlobalStiffnessMatrix(arma::sp_mat* global_stiffness_matrix, Mesh* mesh, Material* material, arma::umat* displacement_node_labels,
                                   arma::umat* force_node_labels, int start_element, int step){
    //Allocate memory
    thread_local arma::mat element_stiffness_matrix = arma::mat(8, 8, arma::fill::zeros);
    thread_local arma::mat B_matrix = arma::mat(3,8, arma::fill::zeros);
    thread_local arma::mat J_matrix = arma::mat(2,2, arma::fill::zeros);
    thread_local arma::mat gauss_quadrature = arma::mat(4,2, arma::fill::zeros);
    thread_local arma::mat local_shape_gradient = arma::mat(2,4, arma::fill::zeros);
    thread_local arma::mat global_shape_gradient = arma::mat(2,4, arma::fill::zeros);
    thread_local arma::mat material_tangent = arma::mat(3,3, arma::fill::zeros);

    thread_local arma::mat foo = arma::mat(material->youngs_modulus.as_col()).rows(start_element,start_element+10);
    thread_local arma::mat local_youngs_modulus = arma::mat(material->youngs_modulus.as_col()).rows(start_element, start_element+step);
    thread_local arma::mat local_poissons_ratio = arma::mat(material->poissons_ratio.as_col()).rows(start_element, start_element+step);
    thread_local arma::umat local_element_list = arma::umat(mesh->elements.submat(start_element,0,start_element+step,3));

    gauss_quadrature.col(0) = {-1, 1, -1, 1};
    gauss_quadrature.col(1) = {-1, -1, 1, 1};
    gauss_quadrature = gauss_quadrature * 1 / sqrt(3);

    // iterate through the elements and assign values into global matrix

    thread_local arma::mat::iterator youngs_modulus_iterator = local_youngs_modulus.begin();
    thread_local arma::mat::iterator poissons_ratio_iterator = local_poissons_ratio.begin();
    thread_local arma::umat::iterator node1_iterator = local_element_list.begin_col(0);
    thread_local arma::umat::iterator node2_iterator = local_element_list.begin_col(1);
    thread_local arma::umat::iterator node3_iterator = local_element_list.begin_col(2);
    thread_local arma::umat::iterator node4_iterator = local_element_list.begin_col(3);
    thread_local arma::mat node_points = arma::mat(4,2);
    thread_local arma::umat node_indices = arma::umat(4,1);

    for(; node1_iterator < local_element_list.end_col(0); ++node1_iterator){

        node_points.row(0) = mesh->nodes.row(*node1_iterator-1).cols(1,2);
        node_points.row(1) = mesh->nodes.row(*node2_iterator-1).cols(1,2);
        node_points.row(2) = mesh->nodes.row(*node3_iterator-1).cols(1,2);
        node_points.row(3) = mesh->nodes.row(*node4_iterator-1).cols(1,2);

        node_indices = {(*node1_iterator-1), *node2_iterator-1, *node3_iterator-1, *node4_iterator-1};

        ConstructElementStiffnessMatrix(&element_stiffness_matrix, mesh->element, node_points, &B_matrix, &J_matrix,
                                        &gauss_quadrature, &local_shape_gradient, &global_shape_gradient, &material_tangent,
                                      *youngs_modulus_iterator, *poissons_ratio_iterator);


        // Assign into global stiffness matrix

        for(int row_index = 0; row_index < 4; row_index++){
            int I = node_indices[row_index];
            if (arma::find((*displacement_node_labels-1) == I).is_empty()){
                for(int column_index = 0; column_index < 4; column_index++){
                    int J = node_indices[column_index];

                    // Assign locations and values
                    global_stiffness_matrix->at(2*I, 2*J) += element_stiffness_matrix(2*row_index,2*column_index);

                    // 2
                    global_stiffness_matrix->at(2*I + 1, 2*J) += element_stiffness_matrix(2*row_index + 1,2*column_index);

                    // 3
                    global_stiffness_matrix->at(2*I + 1, 2*J + 1) += element_stiffness_matrix(2*row_index + 1,2*column_index + 1);

                    //4
                    global_stiffness_matrix->at(2*I, 2*J + 1) += element_stiffness_matrix(2*row_index,2*column_index + 1);

                }
            }
        }

        youngs_modulus_iterator++;
        poissons_ratio_iterator++;
        node2_iterator++;
        node3_iterator++;
        node4_iterator++;

    }

}

void AssignBoundaryConditions(arma::sp_mat* global_stiffness_matrix, arma::mat* nodal_force_matrix,
                              arma::umat displacement_node_labels, arma::mat displacement_node_values,
                              arma::umat force_node_labels, arma::mat force_node_values){

    // Edit the stiffness matrix with forces
    arma::umat::iterator nodal_labels_force_iterator = force_node_labels.begin();
    arma::mat::iterator nodal_axial_force_iterator = force_node_values.begin_col(0);
    arma::mat::iterator nodal_lateral_force_iterator = force_node_values.begin_col(1);

    // Edit the matrices in order to solve for displacement
    for(; nodal_labels_force_iterator < force_node_labels.end(); ++nodal_labels_force_iterator){

        nodal_force_matrix->row(2* (int)(*nodal_labels_force_iterator - 1)) = *nodal_axial_force_iterator;
        nodal_force_matrix->row(2* (int)(*nodal_labels_force_iterator - 1) + 1) = *nodal_lateral_force_iterator;

        nodal_axial_force_iterator++;
        nodal_lateral_force_iterator++;
    }

    // Edit the stiffness matrix with displacements
    arma::umat::iterator nodal_labels_displacement_iterator = displacement_node_labels.begin();
    arma::mat::iterator nodal_axial_displacement_iterator = displacement_node_values.begin_col(0);
    arma::mat::iterator nodal_lateral_displacement_iterator = displacement_node_values.begin_col(1);

    // Edit the matrices in order to solve for displacement
    for(; nodal_labels_displacement_iterator < displacement_node_labels.end(); ++nodal_labels_displacement_iterator){

        //global_stiffness_matrix->row(2* (*nodal_labels_displacement_iterator - 1)).zeros();
        //global_stiffness_matrix->row(2* (*nodal_labels_displacement_iterator - 1) + 1).zeros();

        global_stiffness_matrix->at(2* (*nodal_labels_displacement_iterator - 1) + 1, 2* (*nodal_labels_displacement_iterator - 1) + 1) = 1;
        global_stiffness_matrix->at(2* (*nodal_labels_displacement_iterator - 1), 2* (*nodal_labels_displacement_iterator - 1)) = 1;

        nodal_force_matrix->row(2* (*nodal_labels_displacement_iterator - 1)) = *nodal_axial_displacement_iterator;
        nodal_force_matrix->row(2* (*nodal_labels_displacement_iterator - 1) + 1) = *nodal_lateral_displacement_iterator;

        nodal_axial_displacement_iterator++;
        nodal_lateral_displacement_iterator++;
    }


}

void UpdateGlobalStiffnessMatrixMultiThreaded(arma::sp_mat* global_stiffness_matrix, Mesh* mesh, Material* material,
                                                arma::umat* displacement_node_labels, arma::umat* force_node_labels, int number_of_cpus){

    int step = mesh->elements.n_rows / number_of_cpus;
    int start_element = 0;

    std::vector<std::thread> threads;

    for (int i = 0; i < number_of_cpus; i++){
        threads.push_back(std::thread(PopulateGlobalStiffnessMatrix, global_stiffness_matrix, mesh, material, displacement_node_labels,
                                      force_node_labels, start_element, step));
        start_element = start_element + step;
    }

    threads.push_back(std::thread(PopulateGlobalStiffnessMatrix, global_stiffness_matrix, mesh, material, displacement_node_labels,
                                  force_node_labels, start_element, mesh->elements.n_rows - start_element - 1));

    for(std::thread &t : threads){
        if (t.joinable()){
            t.join();
        }
    }

}

