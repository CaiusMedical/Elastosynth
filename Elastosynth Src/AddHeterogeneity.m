function [YM] = AddHeterogeneity(YM_original, inclusion_masks, het_parameters, n_regions)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Add Noisy Heterogeneity

    YM_noise = YM_original + 1000*randn(size(YM_original));
    
    % Induce Regional Heterogeneity in YM
    
    YM_regional = AddPhantomHeterogeneity(YM_noise, inclusion_masks, het_parameters, n_regions);
    
    % Smooth out slightly
    
    YM = imgaussfilt(YM_regional,1);

    figure
    subplot(1,3,1)
    imshow(YM_original,[])
    title("Homogenous")
    colorbar
    
    subplot(1,3,2)
    imshow(YM_noise, [])
    title("Contaminate with Noise")
    colorbar
    
    subplot(1,3,3)
    imshow(YM,[])
    title("Heterogeneous Phantom")
    colorbar

end

