close all
clear all
clc

speed_factor = 20;

addpath("Scratch/")
addpath("/home/matt/Packages_&_Software/Field_II_ver_3_30_linux/")
field_init();

transducer = Transducer;

transducer.central_frequency=5e6;                %  Transducer center frequency [Hz]
transducer.sampling_frequency=100e6;                %  Sampling frequency [Hz]
transducer.speed_of_sound=1540;                  %  Speed of sound [m/s]
transducer.lambda=transducer.speed_of_sound/transducer.central_frequency;             %  Wavelength [m]
transducer.element_width=transducer.lambda;            %  Width of element
transducer.element_height=5/1000;   %  Height of element [m]
transducer.kerf=0.05/1000;          %  Kerf [m]
transducer.focus=[0 0 70]/1000;     %  Fixed focal point [m]
transducer.N_elements=192;          %  Number of physical elements
transducer.N_active=64;             %  Number of active elements 
transducer.focal_zones = [30:20:200]'/1000;
transducer.transmit_focus = 60/1000;          %  Transmit focus

transducer

D = 60/1000;
L = 50/1000;
Z = 10/1000;

%%

I = 0.2*ones(220,200);

[X,Y] = meshgrid(linspace(-L/2,L/2,size(I,2)), linspace(30/1000, D+30/1000, size(I,1)));

mask = (X.^2 + (Y-60/1000).^2 < (10/1000)^2)

I(mask) = 1;
imshow(I)
colorbar

%%

figure
[phantom_positions, phantom_amplitudes] = ImageToScatterers(I, D,L, Z, 100000);
scatter(phantom_positions(:,3), phantom_positions(:,1), 8, phantom_amplitudes,'filled','o')

% [phantom_positions, phantom_amplitudes] = cyst_pht(100000);
% figure
% scatter(phantom_positions(:,3), phantom_positions(:,1), 8, phantom_amplitudes,'filled','o')
% colorbar


phantom = Phantom(phantom_positions, phantom_amplitudes);

imageopts = ImageOpts(128, 40/1000);

n_factors = 2;
max_factor = 2;

signal_deltas = zeros(n_factors,1);
times = zeros(n_factors, 1);

%%
tic
[RF_Data, Tstarts] = GenerateRFLinearArray(phantom, transducer, imageopts, 1/speed_factor);
%%
% f0=3.5e6;                %  Transducer center frequency [Hz]
% fs=100e6;                %  Sampling frequency [Hz]
% c=1540;                  %  Speed of sound [m/s]
% lambda=c/f0;             %  Wavelength [m]
% width=lambda;            %  Width of element
% element_height=5/1000;   %  Height of element [m]
% kerf=0.05/1000;          %  Kerf [m]
% focus=[0 0 70]/1000;     %  Fixed focal point [m]
% N_elements=192;          %  Number of physical elements
% N_active=64;             %  Number of active elements 


%%

f0=transducer.central_frequency;                %  Transducer center frequency [Hz]
fs=transducer.sampling_frequency;                %  Sampling frequency [Hz]
c=transducer.speed_of_sound;                  %  Speed of sound [m/s]
lambda=transducer.lambda;             %  Wavelength [m]
width=transducer.element_width;            %  Width of element
element_height=transducer.element_height;   %  Height of element [m]
kerf=transducer.kerf;          %  Kerf [m]
focus=transducer.focus;     %  Fixed focal point [m]
N_elements=transducer.N_elements;          %  Number of physical elements
N_active=transducer.N_active;    
no_lines=imageopts.no_lines;              %  Number of lines in image
image_width=imageopts.image_width;      %  Size of image sector
d_x=imageopts.d_x; %  Increment for image
imageopts.decimation_factor = 10;

RF_Matrix = RFCellToMat(RF_Data, Tstarts, transducer, imageopts);

%  Read the data and adjust it in time 

% min_sample=0;
% D = 10;
% RF_onematrix = zeros(750, 128);
% for i=1:imageopts.no_lines
% 
%   %  Load the result
% 
%   % cmd=['load rf_data/rf_ln',num2str(i),'.mat'];
%   % disp(cmd)
%   % eval(cmd)
% 
%   %  Find the envelope
% 
%   rf_data = RF_Data{i};
%   tstart = Tstarts(i,1);
% 
%   round(tstart*fs-min_sample)
%   rf_env=abs(hilbert([zeros(round(tstart*fs-min_sample),1); rf_data]));
%   env(1:max(size(rf_env)),i)=rf_env;
%   RF_onematrix(:,i) = rf_data(1:D:7500);
% end

figure
BMODE1 = log(abs(hilbert(RF_Matrix/max(RF_Matrix(:))))+.01);
imshow(imresize(BMODE1, [220,200]),[])
colorbar