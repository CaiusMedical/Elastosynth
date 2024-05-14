addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator")
addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator/FEM Interface Windows/")
addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator/FIELD II Windows")
addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator\Transducers")
addpath 'C:\Users\MattC\OneDrive\Elastosynth\Simulator\Models'
close all
clear all
clc

%%

n_phantoms = 10;

resolution = [256 256];

parameter_table = GeneratePhantomParameterTable(n_phantoms,[1,2],[5,1,10],[1,5],0,0,0,1);
size_params = [80,10];
YM_params = [1.5, 5,3000];
het_params = [1, 5, 1000];

Generation_Types = ["LTI", "LTP", "Simple"];


procedural_parameters = ProceduralParameters(size_params, YM_params, het_params, resolution, 10, 1000)

parameter_table.generation_type = datasample(Generation_Types,n_phantoms)';


[YMs, YMs_heterogeneous, MetaData] = GenerateProceduralPhantom(parameter_table, procedural_parameters);

%% Randomize the transducers

addpath("F:\Jonah Data")

load("transducer_list.mat")

parameter_table.transducer_file = datasample(transducer_list, n_phantoms)';

% % load the old table
% 
% old_table = readtable("ParameterTable.csv");
% 
% parameter_table = [old_table; parameter_table];

%% Generate a boundary condition

boundary_conditions = BoundaryConditions();

boundary_conditions.top_axial = -0.25*ones(1, resolution(1) + 1);   
boundary_conditions.bottom_axial = zeros(1, resolution(1) + 1);

boundary_conditions.top_lateral = zeros(1, resolution(2) + 1);   
boundary_conditions.bottom_lateral = zeros(1, resolution(2) + 1);

%% Generate the RF

GenerateRFOneByOne(parameter_table, boundary_conditions, procedural_parameters, "F:\Jonah Data", 100)