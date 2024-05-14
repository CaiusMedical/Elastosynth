classdef Material
    %MATERIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        youngs_modulus {mustBeNumeric}
        poissons_ratio {mustBeNumeric}
    end
    
    methods
        function obj = Material(youngs_modulus,poissons_ratio)
            %MATERIAL Instantiate the class
            obj.youngs_modulus = youngs_modulus;

            % If its a single value, project it over all pixels
            if (size(poissons_ratio) == 1)
                obj.poissons_ratio = poissons_ratio*ones(size(youngs_modulus))
            else %It is assumed to be the same size
                obj.poissons_ratio = poissons_ratio;
            end
        end
        
        function Material_CXX = ConvertToCXX(obj)
            %METHOD1 Converts MATLAB object to C++ compatible object
            Material_CXX = clib.FEM_Interface.Material_MATLAB;
            Material_CXX.youngs_modulus = flatten(obj.youngs_modulus);
            Material_CXX.poissons_ratio = flatten(obj.poissons_ratio);
        end
    end
end

