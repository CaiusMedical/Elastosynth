function [inclusion_locations, success] = GenerateRandomInclusionLocations(n_inclusions,...
    inclusion_sizes, resolution, allow_overlap, allow_outofbounds, max_tries, min_dist)
%GENERATERANDOMINCLUSIONLOCATIONS This function uses monte carlo
%simulations to randomize inclusion locations.

    inclusion_locations = 9999*ones(n_inclusions,2);

    % Generate Initial Point
    initial_point = GeneratePoint(inclusion_sizes, resolution, allow_outofbounds);
    inclusion_locations(1,:) = initial_point;

    for i = 2:n_inclusions

        valid = logical(zeros(n_inclusions,1));
        new_point = GeneratePoint(inclusion_sizes, resolution, allow_outofbounds);

        if ~allow_overlap
            try_count = 0;
            while any(~valid)
                new_point = GeneratePoint(inclusion_sizes, resolution, allow_outofbounds);
                valid = CheckLocationValidity(inclusion_locations, new_point, inclusion_sizes, i, min_dist);
                try_count = try_count + 1;
    
                if try_count > max_tries
                    success = false;
                    return
                end
    
            end
        end

        inclusion_locations(i,:) = new_point;

    end

    success = true;

end

function valid = CheckLocationValidity(inclusion_locations, point,...
    inclusion_sizes, inclusion_index, min_dist)

    valid = sqrt((inclusion_locations(:,1) - point(1)).^2 + (inclusion_locations(:,2) - point(2)).^2)  > inclusion_sizes +  inclusion_sizes(inclusion_index) + min_dist;

end

function [point] = GeneratePoint(inclusion_sizes, resolution, allow_outofbounds)
% This function generates points based on the inclusion sizes and if out of
% bounds generation is allowed (are inclusions allowed to be partially in
% the phantom

    point = zeros(1,2);

    if ~allow_outofbounds
        point(1,1) = rand(1,1) * (resolution(1)-2*max(inclusion_sizes)) + max(inclusion_sizes);
        point(1,2) = rand(1,1) * (resolution(2)-2*max(inclusion_sizes)) + max(inclusion_sizes);
    else
        point(1,1) = rand(1,1) * resolution(1);
        point(1,2) = rand(1,1) * resolution(2);
    end

end