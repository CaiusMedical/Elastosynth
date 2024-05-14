//
// Created by matt on 05/06/23.
//

#ifndef RECONSTRUCTION_FEM_CODE_MATLAB_WRAPPER_H
#define RECONSTRUCTION_FEM_CODE_MATLAB_WRAPPER_H

#include <vector>
#include <iostream>

struct ReconstructionOptions{

    std::string reconstruction_type;
    std::string coordinate_system_type;
    int axial_nodal_resolution;
    int lateral_nodal_resolution;
    int youngs_modulus_window_size;
    int poissons_ratio_window_size;
    std::string element_type;
    std::vector<double> default_E;
    std::vector<double> default_poissons_ratio;

};

struct FiniteElementResult_MATLAB{

    std::vector<double> axial_stress;
    std::vector<double> lateral_stress;
    std::vector<double> axial_strain;
    std::vector<double> lateral_strain;
    std::vector<double> shear_strain;
    std::vector<double> axial_displacements;
    std::vector<double> lateral_displacements;
};

struct Material_MATLAB{

    std::vector<double> youngs_modulus;
    std::vector<double> poissons_ratio;
};

struct AnalysisOptions{

    std::string coordinate_system_type;
    std::string element_type;
    int axial_nodal_resolution;
    int lateral_nodal_resolution;
};

struct BoundaryStruct{
    std::vector<double> top_axial;
    std::vector<double> top_lateral;

    std::vector<double> right_axial;
    std::vector<double> right_lateral;

    std::vector<double> bottom_axial;
    std::vector<double> bottom_lateral;

    std::vector<double> left_axial;
    std::vector<double> left_lateral;

    std::vector<double> force_axial;
    std::vector<double> force_lateral;
};

FiniteElementResult_MATLAB RunFiniteElementAnalysis(BoundaryStruct boundary_struct, std::vector<int> displacement_dimensions,
                                                    Material_MATLAB material, AnalysisOptions analysis_options);

#endif //RECONSTRUCTION_FEM_CODE_MATLAB_WRAPPER_H
