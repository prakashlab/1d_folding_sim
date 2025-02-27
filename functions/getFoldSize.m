function fold_size = getFoldSize(sheet,fold_id)
    %%%%%%%%% getFoldSize %%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Get's the number of cells in a fold    % % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fold_sites = find(sheet==fold_id);
    fold_size = (max(fold_sites) - min(fold_sites)) + 1;
end

