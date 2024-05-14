function [polar_function] = ROIToPolarFunction(ROI)
%ROITOPOLARFUNCTION Summary of this function goes here
%   Detailed explanation goes here

    boundary = edge(ROI);
    linear_idx = find(boundary);
    [row, col] = ind2sub(size(boundary), linear_idx);

    row = (row - mean(row,"all"))/size(ROI,1);
    col = (col - mean(col,"all"))/size(ROI,1);

    [theta, rho] = cart2pol(col, row);

    polar_coords = [theta rho];

    polar_function = sortrows(polar_coords);

    [polar_function(:,2), polar_function(:,1)] = resample(polar_function(:,2),...
        polar_function(:,1));

    query_points = linspace(-pi+0.03,pi-0.03,500);

    polar_function = interp1(polar_function(:,1), polar_function(:,2), query_points);


end

