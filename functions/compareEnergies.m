function [sheet_tmp,random_choice] = compareEnergies(Energies,sheet_opts)
    %%%%%%%%% compareEnergies %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function finds the minimum value  % % 
    % % in a list, and returns that value and  % %  
    % % the sheet vector associated with that  % % 
    % % value. If no minimum, it makes a       % % 
    % % random choice.                         % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % % Find the minimum energy in the list
    dups = [];
    min(Energies);
    
    num_opts = length(Energies);
    random_choice = false;
    
    % % Check for duplicate energies in the list
    for i=1:num_opts
        if min(Energies) == Energies(i)
            dups(end+1) = i;
        end
    end
    
    % % If there was a duplicate of the minimum energy, randomly choose
    % % which sheet to pick
    if length(dups) > 1
        disp("equal energies, choosing state at random")
        random_choice = true;
        flip = randi(length(dups),1);
        choice = dups(flip);
        
        for i=1:num_opts
            if choice == i
                sheet_tmp = sheet_opts(i,:);
            end
        end
        
    % % If no duplicate, return the minimum energy sheet   
    elseif length(dups) == 1
        sheet_tmp = sheet_opts(dups(1),:);
    end
    
end