
addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator\")
addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator\FEM Interface Windows/")
close all
clear all


%% Generate an arrangement with 2 inclusions, with sizes ranging from 10 pixels to 40 pixels such that they do not touch

n_inclusions = 4;
inclusion_locations = [64 64;256-64 64;64 256-64;256-64 256-64]; % In Quadrants
inclusion_sizes = 30*rand(n_inclusions,1) + 30; % In pixels
YM_ratios = 10*rand(n_inclusions,1) + 5; % at least 1.5x stiffer
resolution = [256 256];
background_YM = 2000; % 2000kPa

[YM, inclusion_masks] = GeneratePhantom(n_inclusions, inclusion_sizes, inclusion_locations, YM_ratios, background_YM, resolution);
imshow(YM,[])
colorbar

%% Add Heterogeneity

YM_final = AddHeterogeneity(YM,inclusion_masks, [500; 2000; 3000; 5000; 3000], 1000)




%% Test RunFiniteElementAnalysis

% Generate test situation

axRes = 257;
latRes = 257;

axial_displacements = repmat(linspace(-0.5,0,axRes)',1,latRes);
lateral_displacements = zeros(axRes,latRes);

imshow(axial_displacements,[])
colorbar

%%

clc

ConfigureFEM();

% Create material definition
material = clib.FEM_Interface.Material_MATLAB;

material.youngs_modulus = flatten(YM_final);
material.poissons_ratio = flatten(0.48*ones(size(axial_displacements)-1));

% Analysis options
analysis_options = clib.FEM_Interface.AnalysisOptions;
analysis_options.coordinate_system_type = "cartesian";
analysis_options.element_type = "PLANE_STRAIN";
analysis_options.axial_nodal_resolution = axRes;
analysis_options.lateral_nodal_resolution = latRes;

% Boundary Conditions
boundary_conditions = clib.FEM_Interface.BoundaryStruct;

%% From Displacements

boundary_conditions.top_axial = axial_displacements(1,:);   
boundary_conditions.bottom_axial = axial_displacements(end,:);

boundary_conditions.top_lateral = lateral_displacements(1,:);   
boundary_conditions.bottom_lateral = lateral_displacements(end,:);

%%

tic

output = clib.FEM_Interface.RunFiniteElementAnalysis(boundary_conditions,...
                                                      size(axial_displacements),...
                                                      material, analysis_options);
toc

%%

axial_disp = reshape(output.axial_displacements.double(), axRes, latRes);
lateral_disp = reshape(output.lateral_displacements.double(), axRes, latRes);

axial_strain = reshape(output.axial_strain.double(),axRes-1, latRes-1);
lateral_strain = reshape(output.lateral_strain.double(),axRes-1, latRes-1);
shear_strain = reshape(output.shear_strain.double(),axRes-1, latRes-1);

axial_stress = reshape(output.axial_stress.double(),axRes-1, latRes-1);
lateral_stress = reshape(output.lateral_stress.double(),axRes-1, latRes-1);

figure
subplot(2,2,1)
imshow(axial_disp,[])
colorbar
title("Axial Displacement", "FontSize",20)

subplot(2,2,2)
imshow(lateral_disp,[])
colorbar
title("Lateral Displacement", "FontSize",20)

subplot(2,2,3)
imshow(axial_strain,[])
colorbar
title("Axial Strain", "FontSize",20)

subplot(2,2,4)
imshow(lateral_strain,[])
colorbar
title("Lateral Strain", "FontSize",20)

%% Generate Synthetic Data

speed_factor = 100;

if (~ispc)
    addpath("FIELD II Linux/")
else
    addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator/FIELD II Windows/")
end

field_init();

transducer = Transducer;

transducer.central_frequency=5e6;                %  Transducer center frequency [Hz]
transducer.sampling_frequency=100e6;                %  Sampling frequency [Hz]
transducer.speed_of_sound=1540;                  %  Speed of sound [m/s]
transducer.lambda=transducer.speed_of_sound/transducer.central_frequency;             %  Wavelength [m]
transducer.element_width=transducer.lambda;            %  Width of element
transducer.element_height=10/1000;   %  Height of element [m]
transducer.kerf=0.1/1000;          %  Kerf [m]
transducer.focus=[0 0 50]/1000;     %  Fixed focal point [m]
transducer.N_elements=192;          %  Number of physical elements
transducer.N_active=64;             %  Number of active elements 
transducer.focal_zones = [30:10:50]'/1000;
transducer.transmit_focus = 50/1000;          %  Transmit focus

addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator\Transducers")
load("L12-3V.mat")

D = 60/1000;
L = 1.2*(transducer.element_width+transducer.kerf)*(transducer.N_elements-transducer.N_active-1) + transducer.kerf;
Z = 10/1000;

%%

[X,Y] = meshgrid(linspace(L/2,-L/2,257),linspace(D,0,257)+0.03)
I = ones(220,200);

mask = (X.^2 + Y.^2 < (6/1000).^2);

I(mask') = 5;
%%

close all

figure
[phantom_positions, phantom_amplitudes] = ImageToScatterers(I, D,L, Z, 10e4);

phantom = Phantom(phantom_positions, phantom_amplitudes);

imageopts = ImageOpts((transducer.N_elements-transducer.N_active)/2, (transducer.element_width+transducer.kerf)*(transducer.N_elements-transducer.N_active),...
    40/1000, 40/1000,10/1000, 10e4,100);
imageopts.decimation_factor = 2;
iamgeopts.axial_FOV = 60/1000;
imageopts.lateral_FOV = 1.2*(transducer.element_width+transducer.kerf)*(transducer.N_elements-transducer.N_active-1) + transducer.kerf;
iamgeopts.slice_thickness = 10/1000;

dispx = interp2(X,Y,axial_disp,phantom_positions(:,1),phantom_positions(:,3));
dispy = interp2(X,Y,lateral_disp,phantom_positions(:,1),phantom_positions(:,3));

%%

figure
subplot(1,2,1)
scatter(phantom_positions(:,1),phantom_positions(:,3),3,dispx)
title("Scatterer Axial Displacements", "FontSize", 20)
colorbar

subplot(1,2,2)
scatter(phantom_positions(:,1),phantom_positions(:,3),3,dispy)
title("Scatterer Lateral Displacements", "FontSize", 20)
colorbar
%%

displacements = zeros(10e4, 3);
displacements(:,3) = dispx/1000;
displacements(:,1) = dispy/1000;

tic
[Frame1, Frame2] = GenerateFramePairLinear(phantom, displacements, transducer, imageopts, speed_factor);
toc

%%
size(Frame1)
Frame1 = Frame1(1:2900,:);
Frame1 = Frame1 ./ max(Frame1(:));

size(Frame2)
Frame2 = Frame2(1:2900,:);
Frame2 = Frame2 ./ max(Frame2(:));

%%

addpath("C:\Users\MattC\OneDrive\Masters\Displacement Estimator Project\AM2D")

params.probe.a_t = 1;
params.probe.fc = 5;
params.probe.fs = 50;
params.L = 50;
params.D = 60;

AM2D = RunAM2D(imresize(Frame1,[2000,256]), imresize(Frame2,[2000,256]), params);

figure
imshow(imresize(AM2D.Axial(41:end-60,11:end-10),[256,256]),[])
colorbar

figure
imshow(imresize(conv2(AM2D.Axial(41:end-60,11:end-10),[-1;0;1],'valid'),[256,256]),[])
colorbar


%%

function A = flatten(B)

    A = B(:)';

end
