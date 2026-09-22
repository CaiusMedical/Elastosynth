close all
clear all
clc
root = ElastosynthSetup();   % adds Elastosynth Src, FEM interface, FIELD II, Transducers, Models

%%

n_phantoms = 10;

resolution = [256 256];

seed = 1;
parameter_table = GeneratePhantomParameterTable(n_phantoms,[1,2],[5,1,10],[1,5],0,0,0,1, seed);
size_params = [80,10];
YM_params = [1.5, 5,3000];
het_params = [1, 5, 1000];


procedural_parameters = ProceduralParameters(size_params, YM_params, het_params, resolution, 10, 1000);

parameter_table.generation_type(:) = "Simple";   % circular inclusions; use "LTI"/"LTP" for PCA shapes

parameter_table


[YMs, YMs_heterogeneous, MetaData] = GenerateProceduralPhantom(parameter_table, procedural_parameters);

%% Randomize the transducers


load("transducer_list.mat")

parameter_table.transducer_file = fullfile(root, "Transducers", datasample(transducer_list, n_phantoms)');

%% Generate a boundary condition

boundary_conditions = BoundaryConditions();

boundary_conditions.top_axial = -0.25*ones(1, resolution(1) + 1);   
boundary_conditions.bottom_axial = zeros(1, resolution(1) + 1);

boundary_conditions.top_lateral = zeros(1, resolution(2) + 1);   
boundary_conditions.bottom_lateral = zeros(1, resolution(2) + 1);

%% Generate the RF

if ~exist("Outputs", "dir"), mkdir("Outputs"); end
GenerateRFOneByOne(parameter_table, boundary_conditions, procedural_parameters, "Outputs", 100)