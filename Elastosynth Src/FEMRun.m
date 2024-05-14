function [MetaDataFEM] = FEMRun(parameter_table, metadata, boundary_conditions)
%FEMRUN Runs FEM based on metadata and adds displacements
%to the metadata

    material = Material(metadata.YM_hetero, 0.45);

    metadata.analysis_options = FEMOpts("cartesian", metadata.FEM_resolution(1)+1,...
        metadata.FEM_resolution(2)+1, parameter_table.FEM_elements);
    
    
    meta_copy = metadata;
    meta_copy.FEMresult = RunFiniteElementAnalysis(metadata.analysis_options,material,boundary_conditions,true);
    MetaDataFEM = meta_copy;
   

end
