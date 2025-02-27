function deltaEnergy = getChunkEnergy(state_ic,state,activity_vector, ...
                                left_zero_count_ic,right_zero_count_ic, ...
                                l_boundary,r_boundary,params)                     
    %%%%%%%%% getChunkEnergy %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This is a function to compare a        % % 
    % % contiguous subset of a perturbed sheet % %  
    % % ("chunk"), to it's initial state and   % % 
    % % report the energy change. This is      % % 
    % % called in resolveConflicts.             % %
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
    

    % % Check if the conflict block had an average right,left,inner,or
    % % outer movement
    left_zero_count_state = 0;
    right_zero_count_state = 0;

    for j=1:length(state)
        if state(j) == 0
            left_zero_count_state = left_zero_count_state + 1;
        else
            break
        end
    end

    for j=length(state):1
        if state(j) == 0
            right_zero_count_state = right_zero_count_state + 1;
        else
            break
        end
    end

    left_zero_diff = left_zero_count_ic - left_zero_count_state;
    right_zero_diff = right_zero_count_ic - right_zero_count_state;

    % % Set the direction based on how the block moved
    direction = 0;
    
    % % For chunks larger than one cell
    if l_boundary ~= r_boundary
        if left_zero_diff == 0 && right_zero_diff == 0 % block doesn't move
            direction = 0;
        elseif left_zero_diff == 0 && right_zero_diff > 0 % block grew on the right
            direction = 3;
        elseif left_zero_diff == 0 && right_zero_diff < 0 % block shrunk on the right
            direction = 4;
        elseif left_zero_diff > 0 && right_zero_diff == 0 % block grew on the left only
            direction = 4;
        elseif left_zero_diff < 0 && right_zero_diff == 0 % block shrunk on the left only
            direction = 3;
        elseif left_zero_diff < 0 && right_zero_diff < 0 % block shrunk on both sides
            direction = 2;
        elseif left_zero_diff > 0 && right_zero_diff > 0 % block grew on both sides
            direction = 1;
        elseif left_zero_diff < 0 && right_zero_diff > 0 % block shrunk on left, grew on right
            direction = 3;
        elseif left_zero_diff > 0 && right_zero_diff < 0 % block grew on left, shrunk on right
            direction = 4;
        end
    % % For chunks with width 1
    else
        if left_zero_diff == 0 % point doesn't move
            direction = 0;
        elseif left_zero_diff > 0 % block grew or moved left or right
            if l_boundary == 1
            direction = 3;
            elseif l_boundary == length(activity_vector)
                direction = 2;
            end
        elseif left_zero_diff < 0 % block shrunk or moved left or right
            if l_boundary == 1
                direction = 2;
            elseif l_boundary == length(activity_vector)
                direction = 3;
            end
        end 
    end
    
    % % Get the junction mat for this chunk
    junctions = getJunctionList(state_ic);
    if isempty(junctions) == true
        junctions = [1 length(state_ic) 0];
    end
    
    % % Get the energy difference of this chunk relative to the initial
    % % condition
    deltaEnergy = checkDeltaEnergy(state_ic,state,direction,junctions,activity_vector,l_boundary,r_boundary,params);
end

