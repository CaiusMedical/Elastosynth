function [parameter_table] = GeneratePhantomParameterTable(n_phantoms, inclusion_range,...
    min_pixel_params, decorrelation_params, allow_outofbounds, allow_overlap,...
    size_dominant, plane_stress)
    %GENERATEPHANTOMPARAMETERTABLE Generates a Phantom Parameter Table for
    %dataset generation

    % Initialize Table
    n_inclusions = randi([inclusion_range(1) inclusion_range(2)], n_phantoms,1);
    transducer_file = strings(n_phantoms, 1);
    metadata_file = strings(n_phantoms, 1);
    output_file = strings(n_phantoms, 1);
    FEM_elements = strings(n_phantoms, 1);
    FEM_elements(:) = "PLANE_STRAIN";
    OOP_displacement = ((decorrelation_params(2)-decorrelation_params(1)).*rand(n_phantoms,1) + decorrelation_params(1));

    % Initialize random number array for relevant parameters (not inclusion number)
    random_array = rand(n_phantoms, 4);
    allow_outofbounds = random_array(:,2) < allow_outofbounds;
    allow_overlap = random_array(:,1) < allow_overlap;
    size_dominant = random_array(:,3) < size_dominant;
    FEM_elements(random_array(:,4) < plane_stress) = "PLANE_STRESS";

    %
    min_pixel_dist = min(min_pixel_params(2)*rand(n_phantoms,1) + min_pixel_params(1), min_pixel_params(3));

    parameter_table = table(n_inclusions, min_pixel_dist, allow_outofbounds, allow_overlap,...
        size_dominant, OOP_displacement, FEM_elements, transducer_file, metadata_file, output_file);

    parameter_table.transducer_file(:) = "Default_Transducer.mat";
    
end

