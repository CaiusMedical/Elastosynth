function [finite_element_result] = RunFiniteElementAnalysis(analysis_options,material, boundary_conditions, visualize)
%RUNFINITEELEMENTANALYSIS Run the finite element procedure

    ConfigureFEM();

    analysis_options = analysis_options.ConvertToCXX();
    boundary_conditions = boundary_conditions.ConvertToCXX();
    material = material.ConvertToCXX();

    output = clib.FEM_Interface.RunFiniteElementAnalysis(boundary_conditions,...
                                                      [analysis_options.axial_nodal_resolution,...
                                                      analysis_options.lateral_nodal_resolution],...
                                                      material, analysis_options);

    finite_element_result = FiniteElementResult(output,analysis_options.axial_nodal_resolution,analysis_options.lateral_nodal_resolution);

    if (visualize)
        finite_element_result.Visualize();
    end

end

