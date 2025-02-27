function jxn_list = getJunctionList(sheet)
    %%%%%%%%% getJunctionList %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function takes a sheet vector     % % 
    % % containing integers from -Inf to Inf   % %  
    % % and returns a junction mat, where      % % 
    % % each row contains the start and end    % % 
    % % indixes of non-zero patches, along w/  % %
    % % the ID for that patch.                 % % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % % Initialize junctions mat
    junctions = [];
    
    % % Get the IDs of all folds and twists in the sheet
    [fold_ids, twist_ids] = getFeatureIDs(sheet);
    
    % % Get the boundaries of folds and save them to the junctions mat
    for i=1:length(fold_ids)
        fold_boundaries = find(sheet==fold_ids(i));
        boundary_A = min(fold_boundaries);
        boundary_B = max(fold_boundaries);
        new = [boundary_A boundary_B fold_ids(i)];
        junctions = [junctions;new];
    end
    
    % % Get the boundaries of twists and save them to the junctions mat
    for i=1:length(twist_ids)
        twist_boundaries = find(sheet==twist_ids(i));
        boundary_A = min(twist_boundaries);
        boundary_B = max(twist_boundaries);
        new = [boundary_A boundary_B twist_ids(i)];
        junctions = [junctions;new];
    end
    
    % % Return the junctions mat
    jxn_list = junctions;
end

