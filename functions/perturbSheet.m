function sheet_p = perturbSheet(sheet_state, direction,jxn_pair,junctions)
    %%%%%%%%% perturbSheet2 %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function performs a local         % % 
    % % perturbation for a single fold motif   % %  
    % % according to topological rules and     % % 
    % % input direction for the perturbation   % % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % % TO DO: need to decide what should happen when adjacent folds are
    % perturbed - convert to neighboring fold, or introduce a flat region
    
    % % Check the width of the fold/twist (1 or >1)
    L = length(sheet_state);
    one_wide = false;
    
    if jxn_pair(1) == jxn_pair(2)
        one_wide = true;
    end
    
    % % 1. Case where BOTH boundaries are moving OUTWARD
    if direction == 1
        
        % % Check whether there are neighboring twists which will be pushed
        sheet_state = pushTwist(sheet_state,jxn_pair,junctions,direction);

        % % Set the left border cell equal to the fold ID
        if jxn_pair(1) ~= 1
            sheet_state(jxn_pair(1)-1) = jxn_pair(3);
        end
        % % Set the right border cell equal to the fold ID
        if jxn_pair(2) ~= L
            sheet_state(jxn_pair(2)+1) = jxn_pair(3);
        end 
    end
    
    % % 2. Case where BOTH boundaries are moving INWARD
    if direction == 2
        sheet_state(jxn_pair(1)) = 0;
        sheet_state(jxn_pair(2)) = 0;
        
        % % If motif not at left edge, set left cell equal to left border
        if jxn_pair(1) ~= 1
            if sheet_state(jxn_pair(1)-1) > 0
                % % Set the left cell equal to the left border cell value
                sheet_state(jxn_pair(1)) = sheet_state(jxn_pair(1)-1);
            end
        end
        
        % % If motif not at right edge, set right cell equal to right border
        if jxn_pair(2) ~= L
            if sheet_state(jxn_pair(2)+1) > 0
                % % Set the right cell equal to the right border cell value
                sheet_state(jxn_pair(2)) = sheet_state(jxn_pair(2)+1);
            end
        end
    end
    
    % % 3. Case where BOTH boundaries are moving RIGHT
    if direction == 3
        % % Check whether there are neighboring twists which will be pushed
        sheet_state = pushTwist(sheet_state,jxn_pair,junctions,direction);
        
        % % Motif is > 1 cell wide
        if one_wide == false
            
            % % If fold is not touching left edge
            if jxn_pair(1) ~= 1
                if sheet_state(jxn_pair(1)-1) > 0
                    % % Set the left cell equal to the left border cell value
                    sheet_state(jxn_pair(1)) = sheet_state(jxn_pair(1)-1);
                else
                    % % Or if at the edge, set the left cell equal to 0
                    sheet_state(jxn_pair(1)) = 0;
                end
            end
            % % If fold is not touching right edge
            if jxn_pair(2) ~=L
                % % Set the right border cell equal to the fold ID
                sheet_state(jxn_pair(2)+1) = jxn_pair(3);
            end

            % % If fold is touching left edge
            if jxn_pair(1) == 1
                sheet_state(1) = 0;
                % % If fold is not touching right edge
                if jxn_pair(2) ~= L
                    sheet_state(jxn_pair(2)+1) = jxn_pair(3);
                end
            end
            
        % % Motif is 1 cell wide
        elseif one_wide == true
            % % Set left junction equal to 0
            sheet_state(jxn_pair(1)) = 0;
            
            % % Set right border cell equal to fold ID
            if jxn_pair(2) ~=L
                sheet_state(jxn_pair(2)+1) = jxn_pair(3);
            end
        end
    end
    
    % % 4. Case where BOTH boundaries are moving LEFT
    if direction == 4
        % % Check whether there are neighboring twists which will be pushed
        sheet_state = pushTwist(sheet_state,jxn_pair,junctions,direction);

        if one_wide == false
            % % If fold is not touching left edge
            if jxn_pair(1) ~= 1
                % % Set the left border cell equal to the fold ID
                sheet_state(jxn_pair(1)-1) = jxn_pair(3);
            end
            
            % % If fold is not touching right edge
            if jxn_pair(2) ~=L
                if sheet_state(jxn_pair(1)+1) > 0
                    % % If not at edge, set right cell to right border value
                    sheet_state(jxn_pair(2)) = sheet_state(jxn_pair(2)+1);
                else
                    % % If at edge, set right cell to 0
                    sheet_state(jxn_pair(2)) = 0;
                end
            end

            % % If fold is touching right edge
            if jxn_pair(2) ==L
                sheet_state(L) = 0;
                
                % % If fold is not touching left edge
                if jxn_pair(1) ~= 1
                    sheet_state(jxn_pair(1)-1) = jxn_pair(3);
                end
            end
            
            % % If fold is touching left edge ADDED MAY 17
            if jxn_pair(1) == 1
                
                % % If fold is not touching right edge
                sheet_state(1) = jxn_pair(3);
                if jxn_pair(2) ~= L
                    sheet_state(jxn_pair(2)) = sheet_state(jxn_pair(2)+1);
                end
            end

        elseif one_wide == true
            % % Set right junction equal to 0
            sheet_state(jxn_pair(2)) = 0;

            if jxn_pair(1) ~= 1
                % % Set left border cell equal to fold ID
                sheet_state(jxn_pair(1)-1) = jxn_pair(3);
            end 
        end
    end

    % % 5. Case where RIGHT boundary is moving RIGHT, and LEFT is STILL
    if direction == 5
        if one_wide == false
            % % Check whether there are neighboring twists which will be pushed
            sheet_state = pushTwist(sheet_state,jxn_pair,junctions,direction);

            if jxn_pair(2) ~=L
                % % Set right border cell to fold ID
                sheet_state(jxn_pair(2)+1) = jxn_pair(3);
            end
        end
    end

    % % 6. Case where RIGHT boundary is moving LEFT, and LEFT is STILL
    if direction == 6
        if one_wide == false
            % % Check whether there are neighboring twists which will be pushed
            sheet_state = pushTwist(sheet_state,jxn_pair,junctions,direction);

            if jxn_pair(2) ~=L
                if sheet_state(jxn_pair(1)+1) > 0
                    % % Set right cell to right border value
                    sheet_state(jxn_pair(2)) = sheet_state(jxn_pair(1)+1);
                else
                    % % Or if at edge, set right cell equal to 0
                    sheet_state(jxn_pair(2)) = 0;
                end
            end

            % % If right cell at right edge, set right cell equal to 0
            if jxn_pair(2) ==L
                sheet_state(L) = 0;
            end
        end
    end

    % % 7. Case where LEFT boundary is moving RIGHT, and RIGHT is STILL
    if direction == 7
        if one_wide == false
            % % Check whether there are neighboring twists which will be pushed
            sheet_state = pushTwist(sheet_state,jxn_pair,junctions,direction);

            if jxn_pair(1) ~= 1
                if sheet_state(jxn_pair(1)-1) > 0
                    % % Set left cell to left border cell value
                    sheet_state(jxn_pair(1)) = sheet_state(jxn_pair(1)-1);
                else
                    % % Or if at the edge, set left cell equal to 0
                    sheet_state(jxn_pair(1)) = 0;
                end
            end

            % % If at left edge, set left cell equal to 0
            if jxn_pair(1) == 1
                sheet_state(1) = 0;
            end
        end
    end

    % % 7. Case where LEFT boundary is moving LEFT, and RIGHT is STILL
    if direction == 8
        if one_wide == false
            % % Check whether there are neighboring twists which will be pushed
            sheet_state = pushTwist(sheet_state,jxn_pair,junctions,direction);

            if jxn_pair(1) ~= 1
                % % Set left border equal to fold ID
                sheet_state(jxn_pair(1)-1) = jxn_pair(3);
            end
        end
    end

    % % Report perturbed sheet
    sheet_p = sheet_state;
end


