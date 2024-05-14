function [YM_img,inclusion_mask] = GenerateClinicalPhantom(parameter_table,...
    procedural_params, type)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    YM_img = procedural_params.YM_params(3) * ones(procedural_params.resolution);

    load("Generative_PCA.mat")

    YM_ratio = procedural_params.YM_params(2)*rand(1,1) + procedural_params.YM_params(1);


    if (type == "LTI")

        "USING LTI FOR GENERATION"

        % Select two random values from PCA_model
        weight = rand(1,1);
        
        Selected_Inclusions = datasample(PCA_model.database, 2);
        Interpolated = weight*Selected_Inclusions(1,:) + (1-weight)*Selected_Inclusions(2,:);
        
        Mean_Inclusion = (Interpolated* PCA_model.eigenvectors' + PCA_model.mu);
        
        inclusion_mask(:,:,1) = logical(PolarFunctionToROI(double(Mean_Inclusion), [0.5, 0.5], [256, 256]));
    
        YM_img(inclusion_mask(:,:,1)) = procedural_params.YM_params(3) * YM_ratio;

    elseif (type == "LTP")

        "USING LTP FOR GENERATION"

        success = false;
        

        while(~success)

            try
                Selected_Inclusions = datasample(PCA_model.database, 1);
                weight = 0.8*randn(1,20);
                bitmask = randi([0 1],1,20);
                Interpolated = weight.*bitmask.*Selected_Inclusions + Selected_Inclusions;
                Inclusion = (Interpolated* PCA_model.eigenvectors' + PCA_model.mu);
                success = true;
            catch
                "LTP FAILED, TRYING AGAIN"

            end

        end

        inclusion_mask(:,:,1) = logical(PolarFunctionToROI(double(Inclusion), [0.5, 0.5], [256, 256]));
    
        YM_img(inclusion_mask(:,:,1)) = procedural_params.YM_params(3) * YM_ratio;
        

end

