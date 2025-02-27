function sheet_IC_mat = generateSheets(L,n,num_ftrs)
    %%%%%%%%% generateSheets %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function generates a matrix  of   % %
    % % initial conditions for the simulation  % %
    % % to use. This is useful as an input to  % %
    % % run_param_sweep, where it would be     % %
    % % important to average a phase space     % %
    % % over many initial states (as is the    % %
    % % case for experiments).                 % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % % Initialize mat to store sheet initial conditions
    sheet_IC_mat = zeros(n,L);
    
    % % Generate n sheets
    for i=1:n
    
        % % How many twists + folds are there going to be in this sheet?
        num_features = randi(num_ftrs,1);
        num_features = num_ftrs;

        % % What fraction of the features will be folds?
        frac_folds = rand(1,1);

        % % How many folds are there?
        num_folds = round(num_features*frac_folds);

        % % How many twists are there?
        num_twists = num_features - num_folds;

        % % Assign fold IDs
        fold_IDs = [1:num_folds];
        
        % % Assign twist IDs
        twist_IDs = -1*[1:num_twists];
                
        % % How wide should each feature be?
        r = rand(1, num_folds+1); % (+ 1 to include flat regions)
        r = r / sum(r);
        r = round(r * (L - num_twists)); % assign widths based on how much sheet is left after accounting for twist defects
        
        % % Convert from floats to integers
        for j=1:length(r)
            if r(j) < 1
                r(j) = 1;
            end
        end
        
        % % Make sure total width still sums to sheet length
        sumw = 0;
        while sumw ~= L-num_twists
            for j=1:length(r)
                if sumw > L-num_twists
                    if r(j) > 1
                       r(j) = r(j) - 1; 
                       break
                    end
                elseif sumw < L-num_twists
                    r(j) = r(j) + 1;
                    break
                end
                if sumw == L-num_twists
                    break
                end
            end
            sumw = sum(r);
        end
        
        % % Make list of width for each feature
        widths = r;
        fold_width_map = zeros(num_folds,2);
        
        % % Get total flat width
        total_flat_width = widths(1);
        
        % % Organized widths for folds
        for j=1:length(fold_IDs)
            fold_width_map(j,:) = [fold_IDs(j),widths(j+1)];
        end
        
        % % March through the sheet
        this_sheet = zeros(1,L);
        flat_width_used = 0;
        folds_used = 0;
        twists_used = 0;
        index = 1;
        
        while index < L
            % % what should go here?
            id = randi(3,1);
            if id == 3 % % Flat
                if flat_width_used < total_flat_width
                    this_sheet(index) = 0;
                    index = index + 1;
                    flat_width_used = flat_width_used + 1;
                else
                    other_opts = [];
                    if folds_used < num_folds
                        other_opts(end+1) = 2;
                    end
                    if twists_used < num_twists
                        other_opts(end+1) = 1;
                    end
                    if isempty(other_opts) == false
                        id = randi(length(other_opts),1); % % try again ; have to use fold or twist
                        id = other_opts(id);
                    else
                        break
                    end
                end
            end
            
            if id == 2 % % Fold
                if folds_used < num_folds
                    fold_id = fold_width_map(folds_used+1,1);
                    fold_width = fold_width_map(folds_used+1,2);
                    this_sheet(index:fold_width) = fold_id;
                    index = index + fold_width;
                    
                    folds_used = folds_used + 1;  
                else
                    other_opts = [];
                    if flat_width_used<total_flat_width
                        other_opts(end+1) = 3;
                    end
                    if twists_used < num_twists
                        other_opts(end+1) = 1;
                    end
                    if isempty(other_opts) == false
                        id = randi(length(other_opts),1); % % try again ; have to use twist of flat
                        id = other_opts(id);
                    else
                        break
                    end
                end
            end
            
            if id == 1 % % Twist
                if twists_used < num_twists
                    twist_id = twist_IDs(twists_used+1);
                    this_sheet(index) = twist_id;
                    index = index + 1;
                    twists_used = twists_used + 1;
                else
                    other_opts = [];
                    if flat_width_used<total_flat_width
                        other_opts(end+1) = 3;
                    end
                    if folds_used < num_folds
                        other_opts(end+1) = 2;
                    end
                    if isempty(other_opts) == false
                        id = randi(length(other_opts),1); % % try again ; have to use fold or flat
                        id = other_opts(id);
                    else
                        break
                    end
                end
            end
        end
        
        % % Add this sheet as a row in the sheet matrix
        sheet_IC_mat(i,:) = this_sheet;
    end
    
    
    
end

