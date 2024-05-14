classdef ImageOpts
    %IMAGEOPTS Class to hold image options for RF data generation
    
    properties
        no_lines {mustBeInteger}
        image_width {mustBeNumeric}
        decimation_factor {mustBePositive, mustBeInteger}
        d_x {mustBeNumeric}
        axial_FOV {mustBeNumeric}
        lateral_FOV {mustBeNumeric}
        slice_thickness {mustBeNumeric}
        n_scatterers {mustBeNumeric}
        speed_factor {mustBeNumeric}
    end
    
    methods
        function obj = ImageOpts(no_lines,image_width, axial_FOV, lateral_FOV,...
                slice_thickness, n_scatterers, speed_factor)
            %IMAGEOPTS Construct an instance of this class
            obj.no_lines = no_lines;
            obj.image_width = image_width;
            obj.d_x = image_width / no_lines;
            obj.axial_FOV = axial_FOV;
            obj.lateral_FOV = lateral_FOV;
            obj.slice_thickness = slice_thickness;
            obj.n_scatterers = n_scatterers;
            obj.speed_factor = speed_factor;
        end
    end
end

