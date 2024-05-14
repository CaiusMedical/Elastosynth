function [parameter_table] = BatchPairGeneration(parameter_table, MetaData, output_path)
%BATCHPAIRGENERATION Generate the final output object with the RF_data

    field_init();
    close all

    wbar = waitbar(0,"Generating Frame Pair Batch")
    n_phantoms = size(MetaData,2);

    imageopts = MetaData.imageopts;

    for i = 1:size(MetaData,2)

            if ~(isfile(strcat(output_path, parameter_table.output_file(i))))

                load(parameter_table.transducer_file(i))
    
                waitbar(i/n_phantoms,wbar,"Generating Frame Pair Batch")
        
                D = imageopts.axial_FOV;
                L = imageopts.lateral_FOV;
                Z = imageopts.slice_thickness;
        
                [X,Y] = meshgrid(linspace(-L/2,L/2,MetaData(i).FEM_resolution(1)+1),linspace(0,D,MetaData(i).FEM_resolution(2)+1)+0.03);
                I = ones(220,200);
            
                [phantom_positions, phantom_amplitudes] = ImageToScatterers(I, D,L, Z, imageopts.n_scatterers);
                
                phantom = Phantom(phantom_positions, phantom_amplitudes);
                
                dispx = interp2(X,Y,MetaData(i).FEMresult.axial_disp,phantom_positions(:,1),phantom_positions(:,3));
                dispy = interp2(X,Y,MetaData(i).FEMresult.lateral_disp,phantom_positions(:,1),phantom_positions(:,3));
    
                displacements = zeros(imageopts.n_scatterers, 3);
                displacements(:,3) = dispx/1000;
                displacements(:,1) = dispy/1000;
                displacements(:,2) = parameter_table.OOP_displacement(i)/1000 * randn(imageopts.n_scatterers,1);
    
                tic
    
                imageopts.speed_factor
                
                [Frame1, Frame2] = GenerateFramePairLinear(phantom, displacements, transducer, imageopts, imageopts.speed_factor);
    
                output.metadata = MetaData(i);
                output.Frame1 = Frame1;
                output.Frame2 = Frame2;
                output.runtime = toc;
                OutputStructs(i) = output;

                size(Frame1)
    
                file_hex = DataHash(output, 'array','hex')
    
                filename = strcat(output_path, file_hex,".mat");
                save(filename, "output")
                parameter_table.output_file(i) = strcat(file_hex,".mat");


                writetable(parameter_table, strcat(output_path, "ParameterTable.csv"));


            else
                "ALREADY SIMULATED"
            end
    
    end

    close(wbar)
end

