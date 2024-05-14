classdef FEMOpts
    %FEMOPTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        coordinate_system_type
        axial_nodal_resolution {mustBeInteger}
        lateral_nodal_resolution {mustBeInteger}
        element_type
    end
    
    methods
        function obj = FEMOpts(coordinate_system_type, axial_nodal_resolution, lateral_nodal_resolution, element_type)
            %FEMOPTS Construct an instance of this class
            %   Instatiate Properties
            obj.coordinate_system_type = coordinate_system_type;
            obj.axial_nodal_resolution = axial_nodal_resolution;
            obj.lateral_nodal_resolution = lateral_nodal_resolution;
            obj.element_type = element_type;
        end
        
        function analysis_options_CXX = ConvertToCXX(obj)
            %METHOD1 Converts MATLAB object to C++ compatible object
            %   Detailed explanation goes here
            analysis_options_CXX = clib.FEM_Interface.AnalysisOptions;
            analysis_options_CXX.coordinate_system_type = obj.coordinate_system_type;
            analysis_options_CXX.element_type = obj.element_type;
            analysis_options_CXX.axial_nodal_resolution = obj.axial_nodal_resolution;
            analysis_options_CXX.lateral_nodal_resolution = obj.lateral_nodal_resolution;
        end
    end
end

