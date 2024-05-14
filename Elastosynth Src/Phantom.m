classdef Phantom
    %PHANTOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        positions {mustBeNumeric}
        amplitudes {mustBeNumeric}
    end
    
    methods
        function obj = Phantom(positions,amplitudes)
            %PHANTOM Construct an instance of this class
            %   Detailed explanation goes here
            obj.positions = positions;
            obj.amplitudes = amplitudes;
        end
        
        function [truncated_positions, truncated_amplitudes] = OptimizeCalculation(obj,start_range, end_range)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            valid = (obj.positions(:,1) < end_range& obj.positions(:,1) > start_range);
            truncated_positions = obj.positions(valid,:);
            truncated_amplitudes = obj.amplitudes(valid);
        end
    end
end

