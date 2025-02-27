function [sheet_r,random_choice] = resolveConflicts(sheet_tmp_list,state_lookup,activity_vector,params)
        %%%%%%%%% resolveConflicts %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % % This function takes in a list of       % % 
        % % sheets, each one corresponding to a    % %  
        % % single folding motif being locally     % % 
        % % perturbed. The sheets in this list     % % 
        % % need to be merged into a single sheet. % %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % % Load parameters
        E_cc = params.E_cc;
        E_cs = params.E_cs;
        E= params.E;
        t= params.t;
        L= params.L;
        epsilon= params.epsilon;
        E_tw = params.E_tw;
        a_cs = params.a_cs;
        E_f = params.E_f;
        
        % % Get the indices of discontiguous fold chunks, which can be
        % % merged independently
        random_choice = false;
        sheet_tmp = [];
        conflict_list = [];
        
        index_list = sum(abs(sheet_tmp_list));
        chunk_indices = find(index_list~=0);
        chunk_boundaries = [];
        start_ind = chunk_indices(1);
        prev_ind = start_ind;
        chunk_indices;
        for i=2:length(chunk_indices)
            diff = chunk_indices(i) - prev_ind;
            prev_ind = chunk_indices(i);
            if diff > 1
                chunk_boundaries(end+1,:) = [start_ind,chunk_indices(i-1)];
                start_ind = chunk_indices(i);
                prev_ind = start_ind;
            end
        end
        chunk_boundaries(end+1,:) = [start_ind,chunk_indices(length(chunk_indices))];
        
        % % Check for columns of sheet_tmp_list which have conflicts (two
        % % non-zeros in the column, indicating two local perturbations
        % % bumped into each other
        for n=1:length(sheet_tmp_list(1,:)) % loop through columns
            val_list = unique(sheet_tmp_list(:,n)); % get unique vals in column
            val_list(val_list == 0) = []; % remove zeros
            if length(val_list) > 1 % col has >1 unique nonzero val
                conflict_list(end+1) = n;
                sheet_tmp(n) = Inf;
            elseif length(val_list) == 1 % col has 1 unique nonzero val
                sheet_tmp(n) = val_list(1);
            elseif isempty(val_list) == true % col has only zeros
                sheet_tmp(n) = 0;
            end

        end
        
        
        % % If no conflicts, combine the states and return the sheet
        if isempty(conflict_list)
            sheet_tmp = [];
            if length(sheet_tmp_list(:,1)) > 2
                for n=1:length(sheet_tmp_list(1,:)) % loop through columns
                    col = sheet_tmp_list(:,n);
                    vals = unique(col);
                    
                    % % If there's only one value in the column, accept that
                    % % value
                    if length(vals) == 1
                        sheet_tmp(n) = vals(1);
                        
                    % % If there's >1 value in the column, accept the one
                    % % that is present in the column a single time
                    elseif length(vals) == 2
                        for i=1:length(vals)
                            counter = 0;
                            for j=1:length(col)
                                if col(j) == vals(i)
                                    counter = counter + 1;
                                end
                            end
                            if counter == 1
                                sheet_tmp(n) = vals(i);
                            end
                        end
                    end
                end
            elseif length(sheet_tmp_list(:,1)) == 2
                sheet_tmp = sheet_tmp_list(end,:);
            end
            
        % % If there are conflicts, decide how to resolve them. Need to decide
        % % what order the perturbations happened in, and choose the lowest
        % % energy option
        else
        
            % % If there are 6 or fewer folds (7 includes 0's), you can
            % % generate a permutation matrix of all possible orders
            if unique(sheet_tmp_list) <= 7 
                
                % % Generate a permutation matrix for all possible orders that local
                % % perturbations could have occured in
                state_lookup_order = perms([1:length(state_lookup(:,1))]);

                merged_sheet_list = [];
                merged_sheet = zeros(1,L);

                for i=1:length(state_lookup_order(:,1))
                    for j=1:state_lookup_order(i,1)
                        ftr = state_lookup(j,2);
                        ind = state_lookup(j,1);
                        low_en_sheet = sheet_tmp_list(ind,:);
                        for k=1:L
                            if low_en_sheet(k) == ftr
                                merged_sheet(k) = ftr;
                            end
                        end
                    end

                    % % Check if merged sheet is a valid sheet
                    validSheet = checkSheetValidity(sheet_tmp_list(1,:), merged_sheet);
                    if validSheet
                        sheet_tmp_list = [sheet_tmp_list;merged_sheet];
                    end
                end
            % % If there are > 6 folds, the permutation matrix will be too
            % % big, so randomly generate an order for the perturbations
            else
                disp("Too many folds; choosing perturbation order randomly")
                sheet_perm = randperm(length(state_lookup(:,1)));

                merged_sheet_list = [];
                merged_sheet = zeros(1,L);

                for j=1:length(sheet_perm)
                    ftr = state_lookup(j,2);
                    ind = state_lookup(j,1);
                    low_en_sheet = sheet_tmp_list(ind,:);
                    for k=1:L
                        if low_en_sheet(k) == ftr
                            merged_sheet(k) = ftr;
                        end
                    end
                end

                % % Check if merged sheet is a valid sheet
                validSheet = checkSheetValidity(sheet_tmp_list(1,:), merged_sheet);
                if validSheet
                    sheet_tmp_list = [sheet_tmp_list;merged_sheet];
                end
            end
        
            % % Loop through sheet_tmp_list and chunk by chunk, choose the
            % % lowest energy sheet
            if isempty(chunk_boundaries) == false
                for i=1:length(chunk_boundaries(:,1))
                    l_boundary = chunk_boundaries(i,1);
                    r_boundary = chunk_boundaries(i,2);
                    sheet_chunk = sheet_tmp_list(:,l_boundary:r_boundary);

                    [best_state,random_choice] = checkLocalEnergy(sheet_chunk,state_lookup,l_boundary,r_boundary,activity_vector,params);
                    sheet_tmp(l_boundary:r_boundary) = best_state;
                end
            end 
        end
        
        % % Report the final merged sheet state
        sheet_r = sheet_tmp;
end

