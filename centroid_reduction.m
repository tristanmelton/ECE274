function [out] = centroid_reduction(centroid_list, radius)
out = [];

for i = 1:size(centroid_list, 1)
    if isempty(out)
        out = centroid_list(i, :);
    else
        flag = 0;
        for j = 1:size(out, 1)
            sub = centroid_list(i, :) - out(j, :);
            dist = sqrt(sub(1)^2 + sub(2)^2);
            if dist < radius
                if flag == 0
                    out(j, :) = (out(j, :) + centroid_list(i, :))/2;
                    flag = 1;
                end
            end
        end
        if flag == false
            out = [out ; centroid_list(i, :)];
        end
    end
end
