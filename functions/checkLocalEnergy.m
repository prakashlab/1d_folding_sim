function [sheet_state,random_choice] = checkLocalEnergy(sheet_chunk,state_lookup,l_boundary,r_boundary,activity_vector,params)
    %%%%%%%%% checkLocalEnergy %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Function called by resolveConflicts    % %
    % % to get the energy associated with a    % %
    % % different possible perturbations in a  % %
    % % chunk subset of the sheet. sheet_chunk % %
    % % is a matrix where columns are a range  % %
    % % in the sheet and rows are different    % %
    % % possible perturbations that could      % %
    % % happen at this chunk.                  % %
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

    % % Set the boundaries of this chunk in the sheet
    jxn_pair = [l_boundary r_boundary];


    % % Get the junctions for the initial condition of this chunk
    IC = sheet_chunk(1,:);
    vals = unique(IC);
    junctions_IC = getJunctionList(IC);
    total_fold_IC = 0;
    total_twist_IC = 0;
    total_flat_IC = 0;
    
    % % Get average position for each folding motif in this chunk initial
    % % condition
    avg_pos_IC = [];
    for i=1:length(junctions_IC(:,1))
        avg_pos_IC(end+1,:) = [mean(junctions_IC(i,1:2)), junctions_IC(i,3)];
    end
    
    % % Get the total amounts of each folding motif in this chunk initial
    % % condition
    for i=1:length(IC)
        if IC(i) == 0
            total_flat_IC = total_flat_IC + 1;
        elseif IC(i) > 0
            total_fold_IC = total_fold_IC + 1;
        elseif IC(i) < 0
            total_twist_IC = total_twist_IC + 1;
        end
    end
    
    % % Get number of left and right 0 sites in this chunk initial
    % % condition
    left_zero_count_ic = 0;
    right_zero_count_ic = 0;
    
    % % Left border 0 count
    for i=1:length(IC)
        if IC(i) == 0
            left_zero_count_ic = left_zero_count_ic + 1;
        else
            break
        end
    end
    % % Right border 0 count
    for i=length(IC):1
        if IC(i) == 0
            right_zero_count_ic = right_zero_count_ic + 1;
        else
            break
        end
    end


    % Compare energies for each possible sheet state
    index = 0;
    min_energy = Inf;
    energies = [];

    for i=2:length(sheet_chunk(:,1))
        state = sheet_chunk(i,:);
        junctions_state = getJunctionList(state);

        if sum(state) == 0
            junctions_state = [1 length(state) 0];
        end
        junctions_state;
        % Get average position and length in state chunk for each feature
        avg_pos_state = [];
        if length(junctions_state(:,1)) == 1
            avg_pos_state(end+1,:) = [mean(junctions_state(1,1:2)), junctions_state(1,2)-junctions_state(1,1),junctions_state(1,3)];
        else
            for j=1:length(junctions_state(:,1))
                avg_pos_state(end+1,:) = [mean(junctions_state(j,1:2)), junctions_state(j,2)-junctions_state(j,1),junctions_state(j,3)];
            end
        end
        
        % Get average displacement relative to IC in state chunk for each feature
        displ_state = [];
        for j=1:length(vals)
            val_len = 0;
            if ismember(vals(j),state) && vals(j) ~= 0
                % get average pos for this ftr in IC
                IC_pos = 0;
                for k=1:length(avg_pos_IC(:,1))
                    if avg_pos_IC(k,2) == vals(j)
                        IC_pos = avg_pos_IC(k,1);
                    end
                end
                % get average pos for this ftr in state
                state_pos = 0;
                for k=1:length(avg_pos_state(:,1))
                    if avg_pos_state(k,3) == vals(j)
                        state_pos = avg_pos_state(k,1);
                        val_len = avg_pos_state(k,2);
                    end
                end
                % get displacement for this ftr in state
                displ = IC_pos - state_pos;
                if val_len == 0
                    val_len = 1;
                end
                displ_state(end+1,:) = [displ, val_len,vals(j)];
            end
        end
        if sum(state) == 0
            displ_state(end+1,:) = [0, 1,state(1)];
        end

        energies(end+1) = getChunkEnergy(IC,state,activity_vector,...
                                        left_zero_count_ic,right_zero_count_ic,...
                                        l_boundary,r_boundary,params); 
                                    
    end

    energies(end+1) = 0;


    sheet_opts = [sheet_chunk(2:length(sheet_chunk(:,1)),:); sheet_chunk(1,:)];
    [sheet_state,random_choice] = compareEnergies(energies,sheet_opts);
    if sum(energies) == 0
        random_choice = 0;
    end
    
end

