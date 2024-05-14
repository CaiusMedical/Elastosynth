close all
clear all
clc

speed_factor = 100;

addpath("Scratch/")

if (~ispc)
    addpath("FIELD II Linux/")
else
    addpath("FIELD II Windows/")
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

[X,Y] = meshgrid(linspace(-L/2,L/2,220),linspace(-D/2,D/2,200))
I = ones(220,200);

mask = (X.^2 + Y.^2 < (6/1000).^2);

I(mask') = 5;

imshow(I,[])
colorbar

%%

close all

figure
[phantom_positions, phantom_amplitudes] = ImageToScatterers(I, D,L, Z, 114000);
scatter(phantom_positions(:,3), phantom_positions(:,1), 8, phantom_amplitudes,'filled','o')

% [phantom_positions, phantom_amplitudes] = cyst_pht(100000);
% figure
% scatter(phantom_positions(:,3), phantom_positions(:,1), 8, phantom_amplitudes,'filled','o')
% colorbar


phantom = Phantom(phantom_positions, phantom_amplitudes);

imageopts = ImageOpts(256, 40/1000);
imageopts.decimation_factor = 2;

coordinates = readmatrix("G:\My Drive\Engineering\Active Projects\ElastoSynth\Displacement Data/Coordinates.csv")./1000;
displacements = readmatrix("G:\My Drive\Engineering\Active Projects\ElastoSynth\Displacement Data/Displacements.csv")./1000;



coordinates(:,2) = coordinates(:,2) - D/2;
d_inf = 0.2/1000;

figure
scatter(coordinates(:,2),coordinates(:,1),8,displacements(:,2)+max(abs(displacements(:,2))))
colorbar

Ux = scatteredInterpolant(coordinates(:,1:2),displacements(:,1));
Uy = scatteredInterpolant(coordinates(:,1:2),displacements(:,2)+max(abs(displacements(:,2))));

dispy = Uy(phantom_positions(:,1), -phantom.positions(:,3)+30/1000)
dispx = Ux(phantom_positions(:,1), -phantom.positions(:,3)+30/1000)

displacements = zeros(114000, 3);
%displacements(:,3) = -d_inf*exp(-50*(phantom.positions(:,3)-30/1000)) + d_inf;
displacements(:,3) = 0.3*dispy;
displacements(:,1) = 0.3*dispx;
displacements(:,2) = (2*rand(114000,1))/1000;

x = linspace(0,50/1000,200);
y = -d_inf*exp(-50*x) + d_inf;
% figure
% plot(x,y)

figure
scatter(phantom_positions(:,3)-30/1000, phantom_positions(:,1), 8, displacements(:,3),'filled','o')
colorbar
%%

close all

[Frame1, Frame2] = GenerateFramePairLinear(phantom, displacements, transducer, imageopts, speed_factor);

save("G:\My Drive\Engineering\Active Projects\ElastoSynth/RF_Data/Frame1_Corrupted.mat", "Frame1")
save("G:\My Drive\Engineering\Active Projects\ElastoSynth/RF_Data/Frame2_Corrupted.mat", "Frame2")


figure
subplot(1,2,1)
BMODE1 = log(abs(hilbert(Frame1/max(Frame1(:))))+.01);
imshow(imresize(BMODE1, [220,200]),[])
colorbar

subplot(1,2,2)
BMODE1 = log(abs(hilbert(Frame2/max(Frame2(:))))+.01);
imshow(imresize(BMODE1, [220,200]),[])
colorbar
