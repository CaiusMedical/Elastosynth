function [YM_img, inclusion_masks] = GeneratePhantom(n_inclusions, inclusion_size,...
    inclusion_locations, YM_ratios, background_YM, resolution)
%GENERATEPHANTOM This function generates a clean phantom for input into the FEM
%module
%   N_inclusions determines the number of inclusions to be added
%   inclusion_size is an array that determines the size of the inclusions
%   as a radius in pixels
%   inclusion_locations determines the centers of each inclusion in pixels
%   YM_ratios determines the ratio of stiffness for each inclusion compared
%   to the background
%   background_YM determines the young's modulus of the background in Pa
%   resolution is an array which determines the resolution of the image
%   outputs the YM_image and boolean masks to identify the inclusion
%   regions

    % validate input compatibility
    if(size(inclusion_size,1) ~= n_inclusions || size(inclusion_locations,1) ~= n_inclusions || size(YM_ratios,1) ~= n_inclusions)

        error("Array sizes for inclusion dimensions and/or locations are not compatible with the number of inclusions, the number of rows must equal the number of desired inclusions")
    end

    % Generate Pixel Location Array
    [Y,X] = meshgrid(1:resolution(2),1:resolution(1));

    % Initialize YM image
    YM_img = background_YM*ones(resolution);

    % Generate Inclusions

    inclusion_masks = zeros(resolution(1), resolution(2), n_inclusions);

    for i = 1:n_inclusions
        inclusion_mask = (X-inclusion_locations(i,1)).^2 + (Y-inclusion_locations(i,2)).^2 < inclusion_size(i,1)^2;
        YM_img(inclusion_mask) = background_YM * YM_ratios(i,1);
        inclusion_masks(:,:,i) = inclusion_mask;
    end
end

