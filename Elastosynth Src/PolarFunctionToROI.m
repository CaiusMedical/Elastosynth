function [ROI_image] = PolarFunctionToCartesian(polar_function, center_point, resolution)
%POLARFUNCTIONTOROI Summary of this function goes here
%   Detailed explanation goes here

    query_points = linspace(-pi,pi,size(polar_function,2));
    ROI_image = zeros(resolution(1), resolution(2));

    [x, y] = pol2cart(interp(query_points,10),interp(polar_function,10));

    x = round((x + center_point(1))*resolution(1));
    y = round((y + center_point(2))*resolution(2));

    ROI_image(sub2ind(resolution,y,x)) = 1;

    se = strel('disk',10);
    ROI_image = imclose(ROI_image,se);

    ROI_image = imfill(ROI_image);

end

