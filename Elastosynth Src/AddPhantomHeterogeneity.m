function YM_out = AddPhantomHeterogeneity(YM, inclusion_masks, standard_deviations, n_regions)
%ADDPHANTOMHETEROGENEITY Adds regional heterogeneity to the phantom
%   This function uses superpixel segmentation to induce regional heterogeneity

    [L, N] = superpixels(mat2gray(YM), n_regions);

    YM_out = zeros(size(YM));
    idx = label2idx(L);
    for labelVal = 1:N
        Idx = idx{labelVal};

        % Determine if this superpixel exists in an inclusion

        inclusion_values = zeros(size(inclusion_masks,3),1);

        for i = 1:size(inclusion_masks,3)

            mask = inclusion_masks(:,:,i);
            inclusion_values(i,1) = mean(mask(Idx)) > 0.8;

        end

        if ~max(inclusion_values)
            standard_deviation = standard_deviations(1);
        else
            [M, I] = max(inclusion_values);
            standard_deviation = standard_deviations(I+1);
        end

        YM_out(Idx) = mean(YM(Idx))+ standard_deviation*randn(1,1);
    end    

end

