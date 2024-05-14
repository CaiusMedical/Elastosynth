//
// Created by matt on 05/06/23.
//

#include "FEM_Interface.h"
#include "CoordinateSystem.h"
#include "Mesh.h"
#include "BoundaryCondition.h"
#include <armadillo>
#include "FiniteElementModel.h"

FiniteElementResult_MATLAB RunFiniteElementAnalysis(BoundaryStruct boundary_struct, std::vector<int> displacement_dimensions,
                                                    Material_MATLAB material, AnalysisOptions analysis_options){
    //Generate Coordinate System
    CoordinateSystem coordinate_system = CoordinateSystem(analysis_options.coordinate_system_type,
                                                          analysis_options.axial_nodal_resolution,
                                                          analysis_options.lateral_nodal_resolution);

    std::vector<BoundaryCondition> boundary_conditions;

    // Generate boundary conditions
    if(!boundary_struct.top_axial.empty()){
        std::cout << "Detected Top Boundary\n";
        arma::mat top_boundary = arma::mat(displacement_dimensions[1],2, arma::fill::zeros);
        top_boundary.col(0) = arma::conv_to<arma::mat>::from(boundary_struct.top_axial);
        top_boundary.col(1) = arma::conv_to<arma::mat>::from(boundary_struct.top_lateral);

        boundary_conditions.push_back(BoundaryCondition("displacement",top_boundary, "top", &coordinate_system));
    }

    if(!boundary_struct.right_axial.empty()){
        std::cout << "Detected Right Boundary\n";
        arma::mat right_boundary = arma::mat(displacement_dimensions[0],2, arma::fill::zeros);
        right_boundary.col(0) = arma::conv_to<arma::mat>::from(boundary_struct.right_axial);
        right_boundary.col(1) = arma::conv_to<arma::mat>::from(boundary_struct.right_lateral);

        boundary_conditions.push_back(BoundaryCondition("displacement", right_boundary, "left", &coordinate_system));
    }

    if(!boundary_struct.bottom_axial.empty()){
        std::cout << "Detected Bottom Boundary\n";
        arma::mat bottom_boundary = arma::mat(displacement_dimensions[1], 2, arma::fill::zeros);
        bottom_boundary.col(0) = arma::conv_to<arma::mat>::from(boundary_struct.bottom_axial);
        bottom_boundary.col(1) = arma::conv_to<arma::mat>::from(boundary_struct.bottom_lateral);

        boundary_conditions.push_back(BoundaryCondition("displacement",bottom_boundary, "bottom", &coordinate_system));
    }

    if(!boundary_struct.left_axial.empty()){
        std::cout << "Detected Left Boundary\n";
        arma::mat left_boundary = arma::mat(displacement_dimensions[0],2, arma::fill::zeros);
        left_boundary.col(0) = arma::conv_to<arma::mat>::from(boundary_struct.left_axial);
        left_boundary.col(1) = arma::conv_to<arma::mat>::from(boundary_struct.left_lateral);

        boundary_conditions.push_back(BoundaryCondition("displacement",left_boundary, "right", &coordinate_system));
    }

    if(!boundary_struct.force_axial.empty()){
        std::cout << "Detected Force Boundary\n";
        arma::mat force_boundary = arma::mat(displacement_dimensions[1],2, arma::fill::zeros);
        force_boundary.col(0) = arma::conv_to<arma::mat>::from(boundary_struct.force_axial);
        force_boundary.col(1) = arma::conv_to<arma::mat>::from(boundary_struct.force_lateral);

        boundary_conditions.push_back(BoundaryCondition("force",force_boundary, "top", &coordinate_system));
    }



    std::vector<int> material_dimensions = {displacement_dimensions[0] - 1, displacement_dimensions[1] - 1};

    Material default_material = Material(material, material_dimensions);

    FiniteElementResult_MATLAB output = FiniteElementResult_MATLAB();
    if (analysis_options.element_type == "PLANE_STRAIN"){
        LinearPlaneStrainElement element = LinearPlaneStrainElement();
        FiniteElementModel finite_element_model = FiniteElementModel(&element, &coordinate_system, boundary_conditions, &default_material);
        finite_element_model.RunModel();
        output.axial_displacements = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().axial_displacements.as_col());
        output.lateral_displacements = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().lateral_displacements.as_col());
        output.axial_strain = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().axial_strain.as_col());
        output.lateral_strain = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().lateral_strain.as_col());
        output.shear_strain = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().shear_strain.as_col());
        output.axial_stress = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().axial_stresses.as_col());
        output.lateral_stress = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().lateral_stresses.as_col());
    }
    else if(analysis_options.element_type == "PLANE_STRESS"){
        LinearPlaneStressElement element = LinearPlaneStressElement();
        FiniteElementModel finite_element_model = FiniteElementModel(&element, &coordinate_system, boundary_conditions, &default_material);
        finite_element_model.RunModel();
        output.axial_displacements = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().axial_displacements.as_col());
        output.lateral_displacements = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().lateral_displacements.as_col());
        output.axial_strain = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().axial_strain.as_col());
        output.lateral_strain = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().lateral_strain.as_col());
        output.shear_strain = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().shear_strain.as_col());
        output.axial_stress = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().axial_stresses.as_col());
        output.lateral_stress = arma::conv_to<std::vector<double>>::from(finite_element_model.GetFiniteElementResult().lateral_stresses.as_col());
    }
    else{
        throw std::invalid_argument("Invalid element type, refer to documentation for valid elements");
    }

    return output;

}