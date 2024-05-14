addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator")
addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator/FEM Interface Windows/")
addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator/FIELD II Windows")
close all
clear all
clc

%%

resolution = [256 256];

parameter_table = GeneratePhantomParameterTable(50,[1,2],[5,1,10],[0,0],0,0,0,1);
size_params = [80,10];
YM_params = [1.5, 5,3000];
het_params = [1, 5, 1000];

procedural_parameters = ProceduralParameters(size_params, YM_params, het_params, resolution, 10, 1000)

parameter_table


[YMs, YMs_heterogeneous, MetaData] = GenerateProceduralPhantom(parameter_table, procedural_parameters);

%%

axial_displacements = repmat(linspace(-0.25,0,resolution(1)+1)',1,resolution(2)+1);
lateral_displacements = zeros(resolution(1)+1,resolution(2)+1);

imshow(axial_displacements,[])
colorbar

%%
clc

boundary_conditions = BoundaryConditions();

boundary_conditions.top_axial = axial_displacements(1,:);   
boundary_conditions.bottom_axial = axial_displacements(end,:);

boundary_conditions.top_lateral = lateral_displacements(1,:);   
boundary_conditions.bottom_lateral = lateral_displacements(end,:);

MetaDataFEM = BatchFEMRun(parameter_table, MetaData, boundary_conditions);

%%
close all

transducer_list = ["Default_Transducer.mat", "L11-5V.mat", "L12-3V.mat"];
size(MetaDataFEM)

for i = 1:size(MetaDataFEM,2)

    transducer_no = randi(3)
    parameter_table.transducer_file(i) = strcat("C:\Users\MattC\OneDrive\Elastosynth\Simulator\Transducers/",...
       transducer_list(transducer_no));

    load(parameter_table.transducer_file(i));

    imageopts = ImageOpts((transducer.N_elements-transducer.N_active)/2, (transducer.element_width+transducer.kerf)*(transducer.N_elements-transducer.N_active),...
    40/1000, 40/1000,10/1000, 10e4,100);
    imageopts.decimation_factor = 2;
    imageopts.axial_FOV = 60/1000;
    imageopts.lateral_FOV = 1.2*(transducer.element_width+transducer.kerf)*(transducer.N_elements-transducer.N_active-1) + transducer.kerf;
    imageopts.slice_thickness = 10/1000;

    MetaDataFEM(i).imageopts = imageopts;

end

writetable(parameter_table, "Outputs/ParameterTable.csv")

%%readtable("Outputs/ParameterTable.csv")

%%

output_path = "Outputs/";

readtable("Outputs/ParameterTable.csv")

parameter_table = BatchPairGeneration(parameter_table, MetaDataFEM, output_path);

parameter_table
