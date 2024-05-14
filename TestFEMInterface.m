%% You will probably encounter an error in linux if you try to build the library
% because of a conflict between versions of a dependancy, run this command to fix it
%export LD_PRELOAD=/lib/x86_64-linux-gnu/libstdc++.so.6 matlab

clc

addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator")
addpath("C:\Users\MattC\OneDrive\Elastosynth\Simulator/FEM Interface Windows/")
close all
clear all

ConfigureFEM();


%% Test RunFiniteElementAnalysis

% Generate test situation

axRes = 221;
latRes = 201;

axial_displacements = repmat(linspace(-0.5,0,axRes)',1,latRes);
lateral_displacements = zeros(axRes,latRes);

imshow(axial_displacements,[])
colorbar
%%

clc

[X,Y] = meshgrid(linspace(-10,10,latRes-1), linspace(-10,10,axRes-1));
YM_Image = 2000*ones(size(axial_displacements)-1);
YM_Image(X.^2+(Y-2).^2 < 10) = 4000;

imshow(YM_Image,[])
colorbar


%%

material = Material(YM_Image, 0.1);
analysis_options = FEMOpts("cartesian", axRes, latRes, "PLANE_STRESS");

boundary_conditions = BoundaryConditions();

boundary_conditions.top_axial = axial_displacements(1,:);   
boundary_conditions.bottom_axial = axial_displacements(end,:);

boundary_conditions.top_lateral = lateral_displacements(1,:);   
boundary_conditions.bottom_lateral = lateral_displacements(end,:);

%%

result = RunFiniteElementAnalysis(analysis_options,material,boundary_conditions,false)

%%

figure
subplot(2,2,1)
imshofigure
subplot(2,2,1)
imshow(result.axial_disp,[])
colorbar
title("Axial Displacement", "FontSize",20)

subplot(2,2,2)
imshow(result.lateral_disp,[])
colorbar
title("Lateral Displacement", "FontSize",20)

subplot(2,2,3)
imshow(result.axial_strain,[])
colorbar
title("Axial Strain", "FontSize",20)

subplot(2,2,4)
imshow(result.lateral_strain,[])
colorbar
title("Lateral Strain", "FontSize",20)
w(result.axial_disp,[])
colorbar
title("Axial Displacement", "FontSize",20)


