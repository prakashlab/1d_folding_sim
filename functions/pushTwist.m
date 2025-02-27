function sheet = pushTwist(sheet_state,jxn_pair, junctions,direction)
    %%%%%%%%% pushTwist %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function is in charge of pushing  % % 
    % % twists around if folds or other twists % %  
    % % bump into then when being perturbed.   % % 
    % % This must happen because twists cannot % %
    % % be resolved without getting kicked out % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    L = length(sheet_state);

    if direction == 1 % BOTH OUTWARD
        width = jxn_pair(1) - jxn_pair(2);
        
        % % Left junction
        if jxn_pair(1) ~= 1
            
            % % Check the immediate left neighbor of the left jxn
            neighbor_l = sheet_state(jxn_pair(1)-1);
            
            % % If the neighbor is a twist, bump the twist to left in junctions
            % % and propagate to the left until reaching pos 1
            pos = jxn_pair(1);
            while pos > 1
                if neighbor_l < 0 && neighbor_l ~= jxn_pair(3)
                    % get jxn info for neighbor
                    jxn_info = [];
                    which_jxn = 0;
                    for i=1:length(junctions(:,1))
                        if junctions(i,3) == neighbor_l
                            jxn_info = junctions(i,:);
                            which_jxn = i;
                        end
                    end
                    if isempty(jxn_info) == false
                        if jxn_info(1) ~= 1
                            jxn_info(1) = jxn_info(1)-1;
                            jxn_info(2) = jxn_info(2)-1;
                            junctions(which_jxn,:) = jxn_info;
                        elseif jxn_info(1) == 1 && jxn_info(2) ~= 1
                            jxn_info(2) = jxn_info(2)-1;
                            junctions(which_jxn,:) = jxn_info; 
                        elseif jxn_info(1) == 1 && jxn_info(2) == 1
                            junctions1 = junctions(1:which_jxn-1,:);
                            junctions1 = vertcat(junctions1,junctions(which_jxn+1:length(junctions(:,1)),:));
                            junctions = junctions1;
                        end
                    end
                    if isempty(jxn_info) == false
                        pos = jxn_info(1);
                    else
                        pos = 1;
                    end
                    if pos ~= 1
                        neighbor_l = sheet_state(pos);
                    end
                else
                    pos = 1;
                end
            end
        end
         % Right junction
        if jxn_pair(2) ~= L
            % check the immediate right neighbor of the right jxn
            neighbor_r = sheet_state(jxn_pair(2)+1);
            % if the neighbor is a twist, bump the twist to right in junctions
            % and propagate to the right until reaching pos L
            pos = jxn_pair(2);
            while pos < L
                if neighbor_r < 0 && neighbor_r ~= jxn_pair(3)
                    jxn_info = [];
                    which_jxn = 0;
                    for i=1:length(junctions(:,1))
                        if junctions(i,3) == neighbor_r
                            jxn_info = junctions(i,:);
                            which_jxn = i;
                        end
                    end
                    if isempty(jxn_info) == false
                        if jxn_info(1) ~= L
                            jxn_info(1) = jxn_info(1)+1;
                            jxn_info(2) = jxn_info(2)+1;
                            junctions(which_jxn,:) = jxn_info;
                        elseif jxn_info(1) == L && jxn_info(2) ~= L
                            jxn_info(2) = jxn_info(2)+1;
                            junctions(which_jxn,:) = jxn_info; 
                        elseif jxn_info(1) == L && jxn_info(2) == L
                            junctions1 = junctions(1:which_jxn-1,:);
                            junctions1 = vertcat(junctions1,junctions(which_jxn+1:length(junctions(:,1)),:));
                            junctions = junctions1;
                        end
                    end
                    if isempty(jxn_info) == false
                        pos = jxn_info(2);
                    else
                        pos = L;
                    end
                    if pos < L
                        neighbor_r = sheet_state(pos);
                    end
                else
                    pos = L;
                end
            end
        end
    end


    if direction == 3 %BOTH RIGHT
        % check if width = 1
        width = jxn_pair(1) - jxn_pair(2);
        if jxn_pair(1) ~= L
            % check the immediate right neighbor of the left jxn
            neighbor_l = sheet_state(jxn_pair(1)+1);
            % if the neighbor is a twist, bump the twist to right in junctions
            % and propagate to the right until reaching pos L
            pos = jxn_pair(2);
            while pos < L
                if neighbor_l < 0 && neighbor_l ~= jxn_pair(3)
                    jxn_info = [];
                    which_jxn = 0;
                    for i=1:length(junctions(:,1))
                        if junctions(i,3) == neighbor_l
                            jxn_info = junctions(i,:);
                            which_jxn = i;
                        end
                    end
                    if isempty(jxn_info) == false
                        if jxn_info(1) ~= L
                            jxn_info(1) = jxn_info(1)+1;
                            jxn_info(2) = jxn_info(2)+1;
                            junctions(which_jxn,:) = jxn_info;
                        elseif jxn_info(2) == L && jxn_info(1) ~= L
                            jxn_info(1) = jxn_info(1)+1;
                            junctions(which_jxn,:) = jxn_info; 
                        elseif jxn_info(1) == L && jxn_info(2) == L
                            junctions1 = junctions(1:which_jxn-1,:);
                            junctions1 = vertcat(junctions1,junctions(which_jxn+1:length(junctions(:,1)),:));
                            junctions = junctions1;
                        end
                    end
                    if isempty(jxn_info) == false
                        pos = jxn_info(2);
                    else
                        pos = L;
                    end
                    if pos < L
                        neighbor_l = sheet_state(pos);
                    end
                else
                    pos = L;
                end
            end
        end
        if width ~= 0
            if jxn_pair(2) ~=L
                % check the immediate right neighbor of the right jxn
                neighbor_r = sheet_state(jxn_pair(2)+1);
                % if the neighbor is a twist, bump the twist to right in junctions
                % and propagate to the right until reaching pos L
                pos = jxn_pair(2);
                while pos < L
                    if neighbor_r < 0 && neighbor_r ~= jxn_pair(3)
                        jxn_info = [];
                        which_jxn = 0;
                        for i=1:length(junctions(:,1))
                            if junctions(i,3) == neighbor_r
                                jxn_info = junctions(i,:);
                                which_jxn = i;
                            end
                        end
                        if isempty(jxn_info) == false
                            if jxn_info(1) ~= L
                                jxn_info(1) = jxn_info(1)+1;
                                jxn_info(2) = jxn_info(2)+1;
                                junctions(which_jxn,:) = jxn_info;
                            elseif jxn_info(2) == L && jxn_info(1) ~= L
                                jxn_info(1) = jxn_info(1)+1;
                                junctions(which_jxn,:) = jxn_info; 
                            elseif jxn_info(1) == L && jxn_info(2) == L
                                junctions1 = junctions(1:which_jxn-1,:);
                                junctions1 = vertcat(junctions1,junctions(which_jxn+1:length(junctions(:,1)),:));
                                junctions = junctions1;
                            end
                        end
                        if isempty(jxn_info) == false
                            pos = jxn_info(2);
                        else
                            pos = L;
                        end
                        if pos < L
                            neighbor_r = sheet_state(pos);
                        end
                    else
                        pos = L;
                    end
                end
            end
        end
    end

    if direction == 4 %BOTH LEFT
        % check if width = 1
        width = jxn_pair(1) - jxn_pair(2);
        if jxn_pair(1) ~= 1
            % check the immediate left neighbor of the left jxn
            neighbor_l = sheet_state(jxn_pair(1)-1);
            % if the neighbor is a twist, bump the twist to left in junctions
            % and propagate to the left until reaching pos 1
            pos = jxn_pair(1);
            while pos > 1
                if neighbor_l < 0 && neighbor_l ~= jxn_pair(3)
                    jxn_info = [];
                    which_jxn = 0;
                    for i=1:length(junctions(:,1))
                        if junctions(i,3) == neighbor_l
                            jxn_info = junctions(i,:);
                            which_jxn = i;
                        end
                    end
                    if isempty(jxn_info) == false
                        if jxn_info(1) ~= 1
                            jxn_info(1) = jxn_info(1)-1;
                            jxn_info(2) = jxn_info(2)-1;
                            junctions(which_jxn,:) = jxn_info;
                        elseif jxn_info(1) == 1 && jxn_info(2) ~= 1
                            jxn_info(2) = jxn_info(2)-1;
                            junctions(which_jxn,:) = jxn_info; 
                        elseif jxn_info(1) == 1 && jxn_info(2) == 1
                            junctions1 = junctions(1:which_jxn-1,:);
                            junctions1 = vertcat(junctions1,junctions(which_jxn+1:length(junctions(:,1)),:));
                            junctions = junctions1;
                        end
                    end
                    if isempty(jxn_info) == false
                        pos = jxn_info(1);
                    else
                        pos = 1;
                    end
                    if pos > 1
                        neighbor_l = sheet_state(pos);
                    end
                else
                    pos = 1;
                end
            end
        end
        if width ~= 0
            if jxn_pair(2) ~=L
                % check the immediate left neighbor of the right jxn
                neighbor_r = sheet_state(jxn_pair(2)-1);
                % if the neighbor is a twist, bump the twist to left in junctions
                % and propagate to the left until reaching pos 1
                pos = jxn_pair(1);
                while pos > 1
                    if neighbor_l < 0 && neighbor_l ~= jxn_pair(3)
                        jxn_info = [];
                        which_jxn = 0;
                        for i=1:length(junctions(:,1))
                            if junctions(i,3) == neighbor_l
                                jxn_info = junctions(i,:);
                                which_jxn = i;
                            end
                        end
                        if isempty(jxn_info) == false
                            if jxn_info(1) ~= 1
                                jxn_info(1) = jxn_info(1)-1;
                                jxn_info(2) = jxn_info(2)-1;
                                junctions(which_jxn,:) = jxn_info;
                            elseif jxn_info(1) == 1 && jxn_info(2) ~= 1
                                jxn_info(2) = jxn_info(2)-1;
                                junctions(which_jxn,:) = jxn_info; 
                            elseif jxn_info(1) == 1 && jxn_info(2) == 1
                                junctions1 = junctions(1:which_jxn-1,:);
                                junctions1 = vertcat(junctions1,junctions(which_jxn+1:length(junctions(:,1)),:));
                                junctions = junctions1;
                            end
                        end
                        if isempty(jxn_info) == false
                            pos = jxn_info(1);
                        else
                            pos = 1;
                        end
                        if pos > 1
                            neighbor_l = sheet_state(pos);
                        end
                    else
                        pos = 1;
                    end
                end
            end
        end
    end
    
    
    if direction == 5 %RIGHT MOVING RIGHT, LEFT STILL
        % check if width = 1
        width = jxn_pair(1) - jxn_pair(2);
        if width ~= 0
            if jxn_pair(2) ~=L
                % check the immediate right neighbor of the right jxn
                neighbor_r = sheet_state(jxn_pair(2)+1);
                % if the neighbor is a twist, bump the twist to right in junctions
                % and propagate to the right until reaching pos L
                pos = jxn_pair(2);
                while pos < L
                    if neighbor_r < 0 && neighbor_r ~= jxn_pair(3)
                        jxn_info = [];
                        which_jxn = 0;
                        for i=1:length(junctions(:,1))
                            if junctions(i,3) == neighbor_r
                                jxn_info = junctions(i,:);
                                which_jxn = i;
                            end
                        end
                        if isempty(jxn_info) == false
                            if jxn_info(1) ~= L
                                jxn_info(1) = jxn_info(1)+1;
                                jxn_info(2) = jxn_info(2)+1;
                                junctions(which_jxn,:) = jxn_info;
                            elseif jxn_info(2) == L && jxn_info(1) ~= L
                                jxn_info(1) = jxn_info(1)+1;
                                junctions(which_jxn,:) = jxn_info; 
                            elseif jxn_info(1) == L && jxn_info(2) == L
                                junctions1 = junctions(1:which_jxn-1,:);
                                junctions1 = vertcat(junctions1,junctions(which_jxn+1:length(junctions(:,1)),:));
                                junctions = junctions1;
                            end
                        end
                        if isempty(jxn_info) == false
                            pos = jxn_info(2);
                        else
                            pos = L;
                        end
                        if pos < L
                            neighbor_r = sheet_state(pos);
                        end
                    else
                        pos = L;
                    end
                end
            end
        end
    end
    
    
    
    if direction == 8 %LEFT MOVING LEFT, RIGHT STILL
        % check if width = 1
        width = jxn_pair(1) - jxn_pair(2);
        if jxn_pair(1) ~= 1
            % check the immediate left neighbor of the left jxn
            neighbor_l = sheet_state(jxn_pair(1)-1);
            % if the neighbor is a twist, bump the twist to left in junctions
            % and propagate to the left until reaching pos 1
            pos = jxn_pair(1);
            while pos > 1
                if neighbor_l < 0 && neighbor_l ~= jxn_pair(3)
                    jxn_info = [];
                    which_jxn = 0;
                    for i=1:length(junctions(:,1))
                        if junctions(i,3) == neighbor_l
                            jxn_info = junctions(i,:);
                            which_jxn = i;
                        end
                    end
                    if isempty(jxn_info) == false
                        if jxn_info(1) ~= 1
                            jxn_info(1) = jxn_info(1)-1;
                            jxn_info(2) = jxn_info(2)-1;
                            junctions(which_jxn,:) = jxn_info;
                        elseif jxn_info(1) == 1 && jxn_info(2) ~= 1
                            jxn_info(2) = jxn_info(2)-1;
                            junctions(which_jxn,:) = jxn_info; 
                        elseif jxn_info(1) == 1 && jxn_info(2) == 1
                            junctions1 = junctions(1:which_jxn-1,:);
                            junctions1 = vertcat(junctions1,junctions(which_jxn+1:length(junctions(:,1)),:));
                            junctions = junctions1;
                        end
                    end
                    if isempty(jxn_info) == false
                        pos = jxn_info(1);
                    else
                        pos = 1;
                    end
                    if pos > 1
                        neighbor_l = sheet_state(pos);
                    end
                else
                    pos = 1;
                end
            end
        end
    end
    
    % % Build sheet from modified junctions
    sheet = zeros(1,length(sheet_state));
    for i=1:length(junctions(:,1))
        jxn_info = junctions(i,:);
        for j=jxn_info(1):jxn_info(2)
            if j <= length(sheet_state)
                sheet(j) = jxn_info(3);
            end
        end
        
    end

end

