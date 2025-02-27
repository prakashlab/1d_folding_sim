function [activity_vector, activity_jxns] = initActivityVector(junctions,sheet,flocking_coherence_time,flocking_mode,counter,activity_vector1)
    %%%%%%%%% initActivityVector %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function takes in a sheet with    % % 
    % % certain folded, twisted, and flat      % %  
    % % regions and assigns activity           % % 
    % % orientations (left or right) to each   % % 
    % % flat patch, either randomly or based   % %
    % % on the previous timestep's activity    % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % % Set orientations    
    left_facing = -1; % Should be set to -1
    right_facing = 1; % Should be set to 1
    
    % % Check whether the activity vector should be coherent with the
    % previous timesteps activity vector.
    check_time = mod(counter-2, flocking_coherence_time);
    
    % % Mode 1: folds and twists inhibit patch communication
    if flocking_mode == 1
        
        % % If no coherence, randomly initialize patch orientations
        if check_time == 0
            sheet_state = sheet == 0;

            % % Set up activity vector skeleton based on where sheet is flat
            if sum(sheet_state) == 0
                activity_vector = zeros(1,length(sheet));
                activity_jxns = getJunctionList(activity_vector);
            else
                % % Randomly assign 1 or -1 to all flat sites
                activity_vector = [];
                for i=1:length(sheet_state)
                    flip = randi(2,1);
                    if flip == 2
                        activity_vector(i) = sheet_state(i)*left_facing; %left force: sheet_state(i)*left_facing;
                    elseif flip == 1
                        activity_vector(i) = sheet_state(i)*right_facing; %right force: sheet_state(i)*right_facing
                    end
                end

                % % Find the indexes of the AV which are flat
                flat_boundaries = find(activity_vector==right_facing | activity_vector == left_facing);

                % % Find the indexes of the AV which mark the start and end of
                % % discontiguous flat patches
                flat_boundaries2 = [];
                flat_boundaries2(end+1) = flat_boundaries(1);
                prev_val = flat_boundaries(1);

                for i=2:length(flat_boundaries)
                    diff = flat_boundaries(i)-prev_val;
                    if diff > 1
                        flat_boundaries2(end+1) = prev_val;
                        flat_boundaries2(end+1) = flat_boundaries(i);
                    end
                    prev_val = flat_boundaries(i);
                end

                flat_boundaries2(end+1) = flat_boundaries(end);
                activity_jxns = [];
                counter = 1;

                while counter < length(flat_boundaries2)
                    jxnA = flat_boundaries2(counter);
                    jxnB = flat_boundaries2(counter+1);
                    activity_jxns(end+1,:) = [jxnA jxnB];
                    counter = counter + 2;
                end

                % % Count the 1 vs -1 values in each patch, and set every
                % % orientation in that patch to the one with a greater number
                flat_ids = [];
                flat_id = 1;

                for i=1:length(activity_jxns(:,1))
                    row = activity_jxns(i,:);
                    jxnA = row(1);
                    jxnB = row(2);
                    counter1 = 0;
                    counterneg1 = 0;
                    for j=jxnA:jxnB
                        val = activity_vector(j);
                        if val == right_facing
                            counter1 = counter1 + 1;
                        elseif val == left_facing
                            counterneg1 = counterneg1 + 1;
                        end
                    end

                    first_in_patch = true;
                    for j=jxnA:jxnB
                        if counter1 > counterneg1
                            activity_vector(j) = right_facing;
                            flat_ids(i) = right_facing*flat_id;
                        elseif counterneg1 > counter1
                            activity_vector(j) = left_facing;
                            flat_ids(i) = left_facing*flat_id;
                        elseif counterneg1 == counter1
                            if first_in_patch == true
                                flip = randi(2,1);
                                first_in_patch = false;
                            end
                            if flip == 2
                                activity_vector(j) = left_facing; %left force
                                flat_ids(i) = left_facing*flat_id;
                            elseif flip == 1
                                activity_vector(j) = right_facing; %right force
                                flat_ids(i) = right_facing*flat_id;
                            end
                        end
                    end
                    flat_id = flat_id+1;
                end
                
                activity_jxns = getJunctionList(activity_vector);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % % FOR ANTICORRELATION
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s
                arr_anticorr = [-1,1];
                flip_anticorr = randsample(arr_anticorr,1);
                activity_jxns = getJunctionList(activity_vector);
                junctions;
                if ~isempty(junctions)
                    jj_start = junctions(1);
                    jj_stop = junctions(2);
                    for jj_anticorr=1:length(activity_vector)
                        if jj_anticorr < jj_start
                            activity_vector(jj_anticorr) = flip_anticorr;
                        end

                        if jj_anticorr > jj_stop
                            activity_vector(jj_anticorr) = flip_anticorr*-1;
                        end

                    end
                end
                %activity_vector
                activity_jxns = getJunctionList(activity_vector);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
            end
            
        % % If coherence, initialize patch orientations based on previous timestep
        else
            % % Get indices for sites that don't have an assigned value
            blank_indices = [];
            for i=1:length(sheet)
                if sheet(i) == 0
                    activity_val = activity_vector1(i);
                    if ismember(activity_val,[right_facing,left_facing])==false
                        blank_indices(end+1) = i;
                    end
                elseif sheet(i) ~= 0
                    activity_vector1(i) = 0;
                end
            end
            
            
            % % Group indices into contiguous patches
            if isempty(blank_indices) == false
                blank_indices2 = [];
                blank_indices2(end+1) = blank_indices(1);
                prev_val = blank_indices(1);
                
                
                for i=2:length(blank_indices)
                    diff = blank_indices(i)-prev_val;
                    if diff > 1
                        blank_indices2(end+1) = prev_val;
                        blank_indices2(end+1) = blank_indices(i);
                    end
                    prev_val = blank_indices(i);
                end

                blank_indices2(end+1) = blank_indices(end);
                blank_jxns = [];
                counter = 1;

                while counter < length(blank_indices2)
                    jxnA = blank_indices2(counter);
                    jxnB = blank_indices2(counter+1);
                    blank_jxns(end+1,:) = [jxnA jxnB];
                    counter = counter + 2;
                end
                
                % % Looping through the contiguous patches of blank\ activity sites
                for i=1:length(blank_jxns(:,1))
                    start_jxn = blank_jxns(i,1);
                    end_jxn = blank_jxns(i,2);
                    activity_val_left = 0;
                    activity_val_right = 0;
                    if start_jxn ~= 1
                        activity_val_left = activity_vector1(start_jxn-1);
                    end
                    
                    if end_jxn ~= length(activity_vector1)
                        activity_val_right= activity_vector1(end_jxn+1);
                    end

                    % % Used to be a fold, now 2 patches must merge
                    if ismember(activity_val_left,[right_facing,left_facing]) == true && ismember(activity_val_right,[right_facing,left_facing]) == true 
                        
                        % % Walk backwards in sheet until hitting patch boundary
                        left_count_left = 0; %for section in left direction, num activity vals pointing left
                        left_count_right = 0; %for section in left direction, num activity vals pointing right
                        hit_left_edge = false;
                        left_boundary_index = 0;
                        walker = start_jxn-1;
                        
                        while hit_left_edge == false
                            if walker ~= 1
                                activity_val = activity_vector1(walker);
                            else
                                left_boundary_index = walker;
                                hit_left_edge = true;
                            end
                            if activity_val == right_facing
                                left_count_right = left_count_right + 1;
                            elseif activity_val == left_facing
                                left_count_left = left_count_left + 1;
                            elseif activity_val == 0
                                left_boundary_index = walker + 1;
                                hit_left_edge = true;
                            end
                            walker = walker - 1;
                        end

                        % % Walk forward in sheet until hitting patch boundary
                        right_count_left = 0; %for section in right direction, num activity vals pointing left
                        right_count_right = 0; %for section in right direction, num activity vals pointing right
                        hit_right_edge = false;
                        right_boundary_index = 0;
                        walker = end_jxn+1;
                        while hit_right_edge == false
                            if walker ~= length(activity_vector1)
                                activity_val = activity_vector1(walker);
                            else
                                right_boundary_index = walker;
                                hit_right_edge = true;
                            end
                            if activity_val == right_facing
                                right_count_right = right_count_right + 1;
                            elseif activity_val == left_facing
                                right_count_left = right_count_left + 1;
                            elseif activity_val == 0 || walker == length(activity_vector1)
                                right_boundary_index = walker-1;
                                hit_right_edge = true;
                            end
                            walker = walker + 1;
                        end

                        total_right = left_count_right + right_count_right;
                        total_left = left_count_left + right_count_left;
                        flip = randi(2,1);
                        if flip == 2
                            activity_val_to_set = left_facing;
                        elseif flip == 1
                            activity_val_to_set = right_facing;
                        end
                        
                        for j=left_boundary_index:right_boundary_index
                            if total_right > total_left
                                activity_vector1(j) = right_facing;
                            elseif total_right < total_left
                                activity_vector1(j) = left_facing;
                            elseif total_right == total_left
                                activity_vector1(j) = activity_val_to_set;
                            end
                        end
                        
                    % % Right edge of a fold gained a flat site    
                    elseif ismember(activity_val_left,[right_facing, left_facing]) == true && ismember(activity_val_right,[right_facing, left_facing]) == false
                        activity_vector1(end_jxn) = activity_val_left;
                        
                    % % Left edge of a fold gained a flat site
                    elseif ismember(activity_val_left,[right_facing, left_facing]) == false && ismember(activity_val_right,[right_facing, left_facing]) == true
                        activity_vector1(start_jxn) = activity_val_right;
                        
                    % % New patch forming between folds/twists
                    elseif ismember(activity_val_left,[right_facing, left_facing]) == false && ismember(activity_val_right,[right_facing, left_facing]) == false 
                        flip = randi(2,1);
                        if flip == 2
                            activity_vector1(end_jxn) = left_facing;
                        elseif flip == 1
                            activity_vector1(end_jxn) = right_facing;
                        end
                    end
                end
            end

            activity_vector = activity_vector1;
            activity_jxns = getJunctionList(activity_vector);
        end
        
    % % Mode 2: folds and twists do NOT inhibit patch communication
    elseif flocking_mode == 2
        sheet_state = sheet == 0;
        
        if sum(sheet_state) == 0
            activity_vector = zeros(1,length(sheet));
            activity_jxns = getJunctionList(activity_vector);
        else

            activity_vector = [];
            
            
            flip = randi(2,1);
            for i=1:length(sheet_state)
                % % If no coherence, randomly initialize patch orientations
                if check_time == 0
                    if flip == 2
                        activity_vector(i) = sheet_state(i)*left_facing; %left force
                    elseif flip == 1
                        activity_vector(i) = sheet_state(i)*right_facing; %right force
                    end
                % % If coherence, initialize patch orientations based on previous timestep
                else
                    prev_orientation = nonzeros(unique(activity_vector1));
                    if isempty(prev_orientation) == false 
                        activity_vector(i) = sheet_state(i)*prev_orientation;
                    else
                        activity_vector(i) = 0;
                    end
                end
            end
        end  
        activity_jxns = getJunctionList(activity_vector);
    end
end

