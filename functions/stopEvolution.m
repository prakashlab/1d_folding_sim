function stopEvolving = stopEvolution(sheet_evo,sheet_tmp,counter,random_choice1,random_choice2,manual_cutoff,memory)
    %%%%%%%%% stopEvolution %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function checks whether it is     % %
    % % time to stop evolving the sheet. It    % %
    % % checks for the sheet being totally     % %
    % % flat, totally folded, at a manually    % %
    % % set cutoff, or at a steady state (not  % %
    % % changing for the past few times).      % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % % Assume that the sheet is not done evolving
    evo_done = false;
    
    % % Check how many folded cells are in the sheet
    sheet_state = sheet_tmp ~= 0;
    L = length(sheet_tmp);
    
    % % Check how many distinct folds and twists are in the sheet
    numfolds = unique(sheet_tmp);
    numfolds = nonzeros(numfolds);
    sumfolds = 0;
    for i=1:length(sheet_tmp)
        if sheet_tmp(i) > 0
            sumfolds = sumfolds + 1;
        end
    end
    
    % If the sheet is in a singular fold, stop the evolution
    if length(numfolds) == 1 && sumfolds == L
       disp("sheet is in one fold. stopping evolution")
       evo_done = true;
    end
    
    % If the sheet is completely flat, stop the evolution
    if sum(sheet_state) == 0
       disp("sheet is flat. stopping evolution")
       evo_done = true;
    end
    
    % % If the sheet state has been the same for the past 10 states, stop
    % % the evolution
%     if sheet_evo == sheet_tmp
%         all_same = true;
%         prev_state = memory(1,:);
%         sz = size(memory);
%         for i=2:sz(1)
%             if memory(i,:) ~= prev_state
%                 all_same = false;
%             end
%             prev_state = memory(i,:);
%         end
%         
%         if all_same == true
%             evo_done = true;
%             disp("Reached steady state. Stopping evolution.")
%         end
%     end
    
    % % If the loop has reached the manually set cutoff, stop the evolution
%     if counter == manual_cutoff
%         disp("reached manual stopping point")
%        evo_done = true;
%     end

    % % Report decision to stop or continue
    stopEvolving = evo_done;
end

