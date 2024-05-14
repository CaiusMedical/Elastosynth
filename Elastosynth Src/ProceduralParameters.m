classdef ProceduralParameters
    %PROCEDURALPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        size_params {mustBeNumeric}
        YM_params {mustBeNumeric}
        het_params {mustBeNumeric}
        resolution {mustBeInteger}
        max_tries {mustBeInteger}
        n_regions {mustBeInteger}
        
    end
    
    methods
        function obj = ProceduralParameters(size_params,YM_params, het_params,...
                resolution, max_tries, n_regions)
            obj.size_params = size_params;
            obj.YM_params = YM_params;
            obj.het_params = het_params;
            obj.resolution = resolution;
            obj.max_tries = max_tries;
            obj.n_regions = n_regions;
        end
    end
end

