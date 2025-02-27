function [fold_ids,twist_ids] = getFeatureIDs(sheet)
    %%%%%%%%% getFeatureIDs %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function takes in a sheet and     % % 
    % % returns a list of the unique fold IDs  % %
    % % and twist IDs in that sheet.           % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % % Get all folding motifs in the sheet (nonzero vals)
    feature_ids = unique(sheet);
    feature_ids = nonzeros(feature_ids);

    fold_ids = [];
    twist_ids = [];

    % % Sort the folding motifs into twists (<0) and folds (>0)
    for i=1:length(feature_ids)
        if feature_ids(i) < 0
            twist_ids(end+1) = feature_ids(i);
        elseif feature_ids(i) >= 1
            fold_ids(end+1) = feature_ids(i);
        end
    end
end

