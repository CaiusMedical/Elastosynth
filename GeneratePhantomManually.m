addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator")
addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator/FEM Interface Windows/")
close all
clear all
clc


%% Make a well integrated phantom with a different poisson's ratio compared to the background

[X,Y] = meshgrid(linspace(-100,100,512), linspace(-100,100,512));

inclusion_mask = X.^2 + Y.^2 < 40^2;

YM = 3000*ones(512,512);
YM(inclusion_mask) = 10000;


Nue = 0.40*ones(512,512);
Nue(inclusion_mask) = 0.45;

subplot(1,2,1)
imshow(YM, [])
colorbar

subplot(1,2,2)
imshow(Nue,[])
colorbar

%% Now lets smooth out the YMs so it isnt such a large drop

YM = imgaussfilt(YM,20);
Nue = imgaussfilt(Nue,20);

subplot(1,2,1)
imshow(YM, [])
title("Young's Modulus E")
colorbar

subplot(1,2,2)
imshow(Nue,[])
title("Poisson's Ratio \nu")
colorbar

%% Run the FEM simulation

% Generate test situation

axRes = 513;
latRes = 513;

axial_displacements = repmat(linspace(-0.5,0,axRes)',1,latRes);
lateral_displacements = zeros(axRes,latRes);

imshow(axial_displacements,[])
colorbar

%%

clc

ConfigureFEM();

% Create material definition
material = clib.FEM_Interface.Material_MATLAB;

material.youngs_modulus = flatten(YM);
material.poissons_ratio = flatten(Nue);

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

%%

close all
figure
subplot(2,2,1)
imshow(axial_disp, [], "InitialMagnification", "fit")
title("Axial Displacement")
colorbar

subplot(2,2,3)
imshow(lateral_disp, [], "InitialMagnification", "fit")
title("Lateral Displacement")
colorbar

subplot(2,2,2)
imshow(axial_strain, [], "InitialMagnification", "fit")
title("Axial Strain")
colorbar

subplot(2,2,4)
imshow(lateral_strain, [], "InitialMagnification", "fit")
title("Lateral Strain")
colorbar

%%

close all
figure
subplot(2,4,1)
imshow(axial_disp, [], "InitialMagnification", "fit")
title("Axial Displacement")
colorbar

subplot(2,4,5)
imshow(lateral_disp, [], "InitialMagnification", "fit")
title("Lateral Displacement")
colorbar

subplot(2,4,2)
imshow(axial_strain, [], "InitialMagnification", "fit")
title("Axial Strain")
colorbar

subplot(2,4,3)
imshow(lateral_strain, [], "InitialMagnification", "fit")
title("Lateral Strain")
colorbar

subplot(2,4,4)
imshow(shear_strain, [], "InitialMagnification", "fit")
title("Shear Strain")
colorbar

subplot(2,4,6)
imshow(axial_stress, [], "InitialMagnification", "fit")
title("Axial stress")
colorbar

subplot(2,4,7)
imshow(lateral_stress, [], "InitialMagnification", "fit")
title("Lateral stress")
colorbar

%%

phantom.axial = axial_disp;
phantom.lateral = lateral_disp;

save("poissons_phantom.mat", 'phantom')

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

transducer

D = 40/1000;
L = 40/1000;
Z = 10/1000;

%%

[X,Y] = meshgrid(linspace(-L/2,L/2,513),linspace(0,D,513)+0.03)
I = ones(220,200);

mask = (X.^2 + Y.^2 < (6/1000).^2);

I(mask') = 5;
%%

close all

figure
[phantom_positions, phantom_amplitudes] = ImageToScatterers(I, D,L, Z, 10e5);

phantom = Phantom(phantom_positions, phantom_amplitudes);

imageopts = ImageOpts(128, 40/1000, 40/1000, 40/1000, 10/1000, 10e5,100);
imageopts.decimation_factor = 2;
iamgeopts.axial_FOV = 40/1000;
imageopts.lateral_FOV = 40/1000;
iamgeopts.slice_thickness = 10/1000;

dispx = interp2(X,Y,axial_disp,phantom_positions(:,1),phantom_positions(:,3));
dispy = interp2(X,Y,lateral_disp,phantom_positions(:,1),phantom_positions(:,3));

%%

figure
subplot(1,2,1)
scatter(phantom_positions(:,1),phantom_positions(:,3),3,dispx)

subplot(1,2,2)
scatter(phantom_positions(:,1),phantom_positions(:,3),3,dispy)
%%

displacements = zeros(10e5, 3);
displacements(:,3) = dispx/1000;
displacements(:,1) = dispy/1000;

[Frame1, Frame2] = GenerateFramePairLinear(phantom, displacements, transducer, imageopts, speed_factor);

%%
Frame1 = Frame1(1:2500,:);
Frame1 = Frame1 ./ max(Frame1(:));

Frame2 = Frame2(1:2500,:);
Frame2 = Frame2 ./ max(Frame2(:));

%%

addpath("C:\Users\MattC\OneDrive\Masters\Displacement Estimator Project\GLUE")

params.probe.a_t = 1;
params.probe.fc = 5;
params.probe.fs = 50;
params.L = 50;
params.D = 60;
GLUE = RunGLUE(Frame1, Frame2, params);

figure
imshow(imresize(GLUE.Axial(80:end-80,11:end-10),[256,256]),[])
colorbar

figure
imshow(imresize(conv2(GLUE.Axial(80:end-80,11:end-10),[-1;0;1],'valid'),[256,256]),[])
colorbar

save("poissons_phantom_GLUE.mat", "GLUE")


%%

function A = flatten(B)

    A = B(:)';

end