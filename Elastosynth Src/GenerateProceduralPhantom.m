function [YM_phantoms, YM_phantoms_hetero, MetaData] = ProceduralPhantomGenerator(parameter_table,...
    procedural_params)
    %PROCEDURALPHANTOMGENERATOR This calls the procedural generator logic to
    %randomly generate phantoms

    YM_phantoms = zeros(procedural_params.resolution(1), procedural_params.resolution(2), height(parameter_table));
    YM_phantoms_hetero = zeros(procedural_params.resolution(1), procedural_params.resolution(2), height(parameter_table));

    for i = 1:height(parameter_table)

        phantom_params = parameter_table(i,:);

        if phantom_params.generation_type == "LTI" || phantom_params.generation_type == "LTP"

            [YM, inclusion_mask] = GenerateClinicalPhantom(parameter_table,...
                                                            procedural_params, ...
                                                            phantom_params.generation_type);
            YM_phantoms(:,:,i) = YM;

        else
            "USING SIMPLE GENERATION"
            inclusion_sizes = procedural_params.size_params(2)*rand(phantom_params.n_inclusions,1) + procedural_params.size_params(1);
            YM_ratios = procedural_params.YM_params(2)*rand(phantom_params.n_inclusions,1) + procedural_params.YM_params(1);
    
            [inclusion_locations, success] = GenerateRandomInclusionLocations(phantom_params.n_inclusions,inclusion_sizes,procedural_params.resolution,...
                    phantom_params.allow_overlap, phantom_params.allow_outofbounds, procedural_params.max_tries, phantom_params.min_pixel_dist);
    
            consecutive_failures = 0;
            while ~success
                consecutive_failures = consecutive_failures + 1;
                [inclusion_locations, success] = GenerateRandomInclusionLocations(phantom_params.n_inclusions,inclusion_sizes,procedural_params.resolution,...
                    phantom_params.allow_overlap, phantom_params.allow_outofbounds, procedural_params.max_tries, phantom_params.min_pixel_dist);
                inclusion_sizes = max(inclusion_sizes - consecutive_failures - 5, 2);
            end


            [YM, inclusion_mask] = GeneratePhantom(phantom_params.n_inclusions, inclusion_sizes, inclusion_locations, YM_ratios, procedural_params.YM_params(3), procedural_params.resolution);
            YM_phantoms(:,:,i) = YM;
            
        end

        hets = zeros(phantom_params.n_inclusions+1,1);
        bckgrd_het = procedural_params.het_params(3);
        hets(2:phantom_params.n_inclusions+1) = bckgrd_het*(procedural_params.het_params(1) + rand(phantom_params.n_inclusions, 1)*(procedural_params.het_params(2) - procedural_params.het_params(1)));
        hets(1) = bckgrd_het;

        procedural_params.resolution

        YM_noise = YM + 1000*randn(procedural_params.resolution);
        YM_regional = max(AddPhantomHeterogeneity(YM_noise, inclusion_mask, hets, procedural_params.n_regions),0.5*procedural_params.YM_params(3));
        YM_hetero = imgaussfilt(YM_regional,1);
        YM_phantoms_hetero(:,:,i) = imgaussfilt(YM_regional,1);

        metadata.YM_original = YM;
        metadata.YM_hetero = YM_hetero;
        metadata.inclusion_masks = inclusion_mask;
        metadata.procedural_params.het_params = procedural_params.het_params;
        metadata.procedural_params.YM_params = procedural_params.YM_params;
        metadata.procedural_params.n_regions = procedural_params.n_regions;
        metadata.procedural_params.size_params = procedural_params.size_params;
        metadata.FEM_resolution = procedural_params.resolution;

        MetaData(i) = metadata;

    end

end

