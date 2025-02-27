function new_sheet = nucleateFolds(sheet_tmp,activity_vector, activity_jxns,junctions,nucl_prob,a_cs,flocking_coherence_time,flocking_mode)
    %%%%%%%%% nucleateFolds %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function decides whether/where to % % 
    % % nucleate new folds in a given timestep.% %  
    % % This gives the simulation a potential  % % 
    % % for nonmonotonic fold behavior; else,  % % 
    % % the initial folds will either shrink   % %
    % % or grow                                % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    new_sheet = sheet_tmp;
    
    % % Check if the sheet has some flat regions
    if isempty(activity_jxns) == false

        % % Nucleate folds due to opposing activity forces
        if a_cs > 0
            % % Get the highest fold ID, to know what the next should be
            if isempty(junctions) == false
                last_fold_id = max(junctions(:,3));
            else
                last_fold_id = 0;
            end
            id_list = [];
            prev_val = 0;
            
            % % Make a list of sites where opposing activity orientations
            % % are adjacent
            for i=1:length(activity_vector)
                if activity_vector(i) * prev_val == -1
                    id_list(end+1) = i;
                end
                prev_val = activity_vector(i);  
            end
            
            % % Initiate new folds at these sites
            for i=1:length(id_list)
                new_sheet(id_list(i)-1) = last_fold_id+1;
                new_sheet(id_list(i)) = last_fold_id+1;
                last_fold_id = last_fold_id + 1;
            end
        end
        % % Update junctions and activity_jxns based on new folds
        junctions2 = getJunctionList(new_sheet);
        [~, activity_jxns2] = initActivityVector(junctions2,new_sheet,flocking_coherence_time,flocking_mode,0,activity_vector);
        
        % % Randomly nucleate folds in flat regions with Probability nucl_prob
        if isempty(activity_jxns2) == false
            if isempty(junctions2) == false
                last_fold_id = max(junctions2(:,3));
                
                % % Loop through flat regions in activity vector
                for i=1:length(activity_jxns2(:,1))
                    for j=activity_jxns2(i,1):activity_jxns2(i,2)
                        if activity_vector(j) ~= 0
                            % % Generate random num between 0 and 1
                            y = rand(1,1); 

                            % % If this random num < nucl_prob, initiate a new fold at this location
                            if y <= nucl_prob 
                                new_sheet(j) = last_fold_id + 1;
                                last_fold_id = new_sheet(j);
                            end
                        end
                    end
                end
            end
        end
    end
end

