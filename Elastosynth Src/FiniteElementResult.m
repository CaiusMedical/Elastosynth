classdef FiniteElementResult
    %FINITEELEMENTRESULT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        axial_disp {mustBeNumeric}
        lateral_disp {mustBeNumeric}
        axial_strain {mustBeNumeric}
        lateral_strain {mustBeNumeric}
        shear_strain {mustBeNumeric}
        axial_stress {mustBeNumeric}
        lateral_stress {mustBeNumeric}
        shear_stress {mustBeNumeric}
    end
    
    methods
        function obj = FiniteElementResult(output, axRes, latRes)
            %FINITEELEMENTRESULT Construct an instance of this class
            %   Detailed explanation goes here
            obj.axial_disp = reshape(output.axial_displacements.double(), axRes, latRes);
            obj.lateral_disp = reshape(output.lateral_displacements.double(), axRes, latRes);
            
            obj.axial_strain = reshape(output.axial_strain.double(),axRes-1, latRes-1);
            obj.lateral_strain = reshape(output.lateral_strain.double(),axRes-1, latRes-1);
            obj.shear_strain = reshape(output.shear_strain.double(),axRes-1, latRes-1);
            
            obj.axial_stress = reshape(output.axial_stress.double(),axRes-1, latRes-1);
            obj.lateral_stress = reshape(output.lateral_stress.double(),axRes-1, latRes-1);
        end
        
        function [] = Visualize(obj)
            %METHOD1 Visualize FEM Result
            close all
            figure
            subplot(2,4,1)
            imshow(obj.axial_disp, [], "InitialMagnification", "fit")
            title("Axial Displacement")
            colorbar
            
            subplot(2,4,5)
            imshow(obj.lateral_disp, [], "InitialMagnification", "fit")
            title("Lateral Displacement")
            colorbar
            
            subplot(2,4,2)
            imshow(obj.axial_strain, [], "InitialMagnification", "fit")
            title("Axial Strain")
            colorbar
            
            subplot(2,4,3)
            imshow(obj.lateral_strain, [], "InitialMagnification", "fit")
            title("Lateral Strain")
            colorbar
            
            subplot(2,4,4)
            imshow(obj.shear_strain, [], "InitialMagnification", "fit")
            title("Shear Strain")
            colorbar
            
            subplot(2,4,6)
            imshow(obj.axial_stress, [], "InitialMagnification", "fit")
            title("Axial stress")
            colorbar
            
            subplot(2,4,7)
            imshow(obj.lateral_stress, [], "InitialMagnification", "fit")
            title("Lateral stress")
            colorbar
        end
    end
end

