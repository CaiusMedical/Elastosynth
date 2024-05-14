classdef Transducer
    properties
        central_frequency {mustBeNumeric}
        sampling_frequency {mustBeNumeric}
        speed_of_sound {mustBeNumeric}
        lambda {mustBeNumeric}
        element_width {mustBeNumeric}
        element_height {mustBeNumeric}
        kerf {mustBeNumeric}
        focus {mustBeNumeric}
        N_elements {mustBeInteger}
        N_active {mustBeInteger}
        focal_zones {mustBeNumeric}
        transmit_focus {mustBeNumeric}
    end
end

