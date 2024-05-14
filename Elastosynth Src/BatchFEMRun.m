function [MetaDataFEM] = BatchFEMRun(parameter_table, metadata, boundary_conditions)
%BATCHFEMRUN Runs FEM based on metadata struct array and adds displacements
%to the metadata

    wbar = waitbar(0,"FEM Simulations Running")
    n_phantoms = size(metadata,2);

    for i = 1:size(metadata,2)

        waitbar(i/n_phantoms,wbar,"FEM Simulations Running")
    
        material = Material(metadata(i).YM_hetero, 0.45);

        metadata(i).analysis_options = FEMOpts("cartesian", metadata(i).FEM_resolution(1)+1,...
            metadata(i).FEM_resolution(2)+1, parameter_table.FEM_elements(i));
        
    
        meta_copy = metadata(i);
        meta_copy.FEMresult = RunFiniteElementAnalysis(metadata(i).analysis_options,material,boundary_conditions,false);
        MetaDataFEM(i) = meta_copy;
    
    end

    close(wbar)
   

end

