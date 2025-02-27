function activityEnergy = getActivityContribution(activity_vector,direction,a_cs,jxn_pair,sub_l,sub_r)
    %%%%%%%%% getActivityContribution %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Function to check how activity should  % %
    % % impact the energy associated with a    % %
    % % perturbed sheet. Needs to compare the  % %
    % % directionality of perturbations with   % %
    % % the activity orientations in adjacent  % %
    % % flat patches.                          % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    left_force = 0;
    right_force = 0;
    
    indices = [sub_l:sub_r];
    new_left_ind = indices(jxn_pair(1));
    new_left_right = indices(jxn_pair(2));
    jxn_pair = [new_left_ind new_left_right];
    
    % Get the value of the activity vector to the left of the leftmost
    % jxn, if it's not at the start of the sheet already
    if jxn_pair(1) ~= 1
        jxn_border_left = activity_vector(jxn_pair(1)-1);
        % if the left-adjacent patch in the activity vector is a flat
        % region (i.e. nonzero in the activity vector), assign it a force

        if jxn_border_left ~= 0
            left_force = sum(activity_vector == jxn_border_left);
            % assign it a left-pointing force if negative. Otherwise 
            % leave as right-pointing
            if jxn_border_left < 1
                left_force = left_force * -1;
            end
        end
    elseif jxn_pair(1) == 1
        if sub_l ~= 1
            jxn_border_left = activity_vector(sub_l-1);
            % if the left-adjacent patch in the activity vector is a flat
            % region (i.e. nonzero in the activity vector), assign it a force
            if jxn_border_left ~= 0
                left_force = sum(activity_vector == jxn_border_left);
                % assign it a left-pointing force if negative. Otherwise 
                % leave as right-pointing
                if jxn_border_left < 1
                    left_force = left_force * -1;
                end
            end
        end
    end
    
    % Get the value of the activity vector to the right of the rightmost
    % jxn, if it's not at the end of the sheet already
    if jxn_pair(2) ~= length(activity_vector)
        jxn_border_right = activity_vector(jxn_pair(2)+1);
        % if the right-adjacent patch in the activity vector is a flat
        % region (i.e. nonzero in the activity vector), assign it a force
        if jxn_border_right ~= 0
            right_force = sum(activity_vector == jxn_border_right);
            % assign it a left-pointing force if negative. Otherwise 
            % leave as right-pointing
            if jxn_border_right < 1
                right_force = right_force * -1;
            end
        end
    elseif jxn_pair(2) ~= length(activity_vector)
        if sub_r ~= length(activity_vector)
            jxn_border_right = activity_vector(sub_r+1);
            % if the right-adjacent patch in the activity vector is a flat
            % region (i.e. nonzero in the activity vector), assign it a force
            if jxn_border_right ~= 0
                right_force = sum(activity_vector == jxn_border_right);
                % assign it a left-pointing force if negative. Otherwise 
                % leave as right-pointing
                if jxn_border_right < 1
                    right_force = right_force * -1;
                end
            end
        end
    end

    if jxn_pair(2) == 1
        if sub_r ~=length(activity_vector)
            jxn_border_right = activity_vector(sub_r+1);
            if jxn_border_right ~= 0
                right_force = sum(activity_vector == jxn_border_right);
                if jxn_border_right < 1
                    right_force = right_force * -1;
                end
            end
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now that forces are assigned, determine energy cost based on those
    % forces and the current perturbation direction (out, in, right, left)
    activityEnergy = 1;
    left_cost = 1;
    right_cost = 1;
    if direction == 1 % BOTH OUTWARD (Left moved left, right moved right)
       if left_force > 0 % Left force is right-facing
           left_cost = 1;
       elseif left_force == 0 % Left force is zero
           left_cost = 0;
       else % Left force is left facing
           left_cost = -1;
       end
       if right_force < 0 % Right force is left-facing
           right_cost = 1;
       elseif right_force == 0 % Right force is zero
           right_cost = 0;
       else % Right force is right facing
           right_cost = -1;
       end
    elseif direction == 2 % BOTH INWARD (Left moved right, right moved left)
       if left_force < 0 % Left force is left-facing
           left_cost = 1;
       elseif left_force == 0 % Left force is zero
           left_cost = 0;
       else % Left force is right-facing
           left_cost = -1;
       end
       if right_force > 0 % Right force is right-facing
           right_cost = 1;
       elseif right_force == 0 % Right force is zero
           right_cost = 0;
       else % Right force is left-facing
           right_cost = -1;
       end
    elseif direction == 3 % BOTH RIGHT (Left moved right, right moved right)
       if left_force > 0 % Left force is right-facing
           left_cost = -1;
       elseif left_force == 0 % Left force is zero
           left_cost = 0;
       else % Left force is left-facing
           left_cost = 1;
       end
       if right_force > 0 % Right force is right-facing
           right_cost = -1;
       elseif right_force == 0 % Right force is zero
           right_cost = 0;
       else % Right force is left-facing
           right_cost = 1;
       end
    elseif direction == 4 % BOTH LEFT (Left moved left, right moved left)
       if left_force < 0 % Left force is left-facing
           left_cost = -1;
       elseif left_force == 0 % Left force is zero
           left_cost = 0;
       else % Left force is right-facing
           left_cost = 1;
       end
       if right_force < 0 % Right force is left-facing
           right_cost = -1;
       elseif right_force == 0 % Right force is zero
           right_cost = 0;
       else % Right force is right-facing
           right_cost = 1;
       end
    elseif direction == 5 % RIGHT MOVING RIGHT, LEFT STILL
       if left_force == 0 % Left force is zero
           left_cost = -1;
       elseif left_force ~= 0 % Left force is nonzero
           left_cost = 1;
       end
       
       if right_force <= 0 % Right force is zero or left-facing
           right_cost = 1;
       elseif right_force > 0 % Right force is zero or right-facing
           right_cost = -1;
       end
    elseif direction == 6 %RIGHT MOVING LEFT, LEFT STILL
       if left_force == 0 % Left force is zero
           left_cost = -1;
       elseif left_force ~= 0 % Left force is nonzero
           left_cost = 1;
       end
       if right_force >= 0 % Right force is zero or right-facing
           right_cost = 1;
       elseif right_force < 0 % Right force is left-facing
           right_cost = -1;
       end
    elseif direction == 7 %LEFT MOVING RIGHT, RIGHT STILL
       if left_force <= 0 % Left force is zero or left-facing
           left_cost = 1;
       elseif left_force > 0 % Left force is right-facing
           left_cost = -1;
       end
       if right_force == 0 % Right force is zero
           right_cost = -1;
       elseif right_force ~= 0 % Right force is nonzero
           right_cost = 1;
       end
    elseif direction == 8 %LEFT MOVING LEFT, RIGHT STILL
       if left_force >= 0 % Left force is zero or right-facing
           left_cost = 1;
       elseif left_force < 0 % Left force is left-facing
           left_cost = -1;
       end
       if right_force == 0 % Right force is zero
           right_cost = -1;
       elseif right_force ~= 0 % Right force is nonzero
           right_cost = 1;
       end
    end
    activityEnergy = (abs(left_force)*left_cost+abs(right_force)*right_cost)*a_cs;
    direction;
    right_cost;
    left_cost;
    if a_cs == 0
        activityEnergy = 0;
    end
end

