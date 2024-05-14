classdef BoundaryConditions
    %BOUNDARYCONDITIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
         top_axial {mustBeNumeric}
         top_lateral {mustBeNumeric}
         bottom_axial {mustBeNumeric}
         bottom_lateral {mustBeNumeric}
         left_axial {mustBeNumeric}
         left_lateral {mustBeNumeric}
         right_axial {mustBeNumeric}
         right_lateral {mustBeNumeric}
         force_axial {mustBeNumeric}
         force_lateral {mustBeNumeric}
    end
    
    methods
        function obj = BoundaryConditions()
            %BOUNDARYCONDITIONS Construct an instance of this class
            %   Does nothing right now
        end
        
        function boundary_conditionsCXX = ConvertToCXX(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            boundary_conditionsCXX = clib.FEM_Interface.BoundaryStruct;
            
            boundary_conditionsCXX.top_axial = obj.top_axial;   
            boundary_conditionsCXX.top_lateral = obj.top_lateral;   
            boundary_conditionsCXX.bottom_axial = obj.bottom_axial;
            boundary_conditionsCXX.bottom_lateral = obj.bottom_lateral;
            boundary_conditionsCXX.left_axial = obj.left_axial;
            boundary_conditionsCXX.left_lateral = obj.left_lateral;
            boundary_conditionsCXX.right_axial = obj.right_axial;
            boundary_conditionsCXX.right_lateral = obj.right_lateral;
            boundary_conditionsCXX.force_axial = obj.force_axial;
            boundary_conditionsCXX.force_lateral = obj.force_lateral;
        end
    end
end

