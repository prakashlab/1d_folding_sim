function delta_E = checkDeltaEnergy(start_sheet,end_sheet,direction,junctions,activity_vector,sub_l,sub_r,params)
    %%%%%%%%% checkDeltaEnergy %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Function to get the energy cost of     % %
    % % changing from an initial condition     % %
    % % sheet to a perturbed sheet. Returns    % %
    % % the energy difference between these    % %
    % % two sheets.                            % %
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
    
    % % Get static features for the start and end sheets 
    numfolds = 0;
    numtwist = 0;
    sumtwists = 0;
    sumfolds = 0;
    junctions_perturb = getJunctionList(end_sheet);
    if isempty(junctions_perturb) == true
        junctions_perturb = [1 length(end_sheet) 0];
    end
    
    
    numfolds_0 = 0;
    numtwist_0 = 0;
    sumtwists_0 = 0;
    sumfolds_0 = 0;

    
    if isempty(junctions_perturb) == false
        % % Count the number of folds and twists in the end_sheet
        for i=1:length(junctions_perturb(:,1))
            if junctions_perturb(i,3) < 0
                numtwist = numtwist + 1;
            elseif junctions_perturb(i,3) > 0
                numfolds = numfolds + 1;
            end
        end
        % % Count total number of sites in folds and twists in the end_sheet
        for i=1:length(end_sheet)
            if end_sheet(i) < 0
                sumtwists = sumtwists + 1;
            elseif end_sheet(i) >= 1
                sumfolds = sumfolds + 1;
            end
        end
    end
    
    % % Count the number of folds and twists in the start_sheet
    for i=1:length(junctions(:,1))
        if junctions(i,3) < 0
            numtwist_0 = numtwist_0 + 1;
        elseif junctions(i,3) > 0
            numfolds_0 = numfolds_0 + 1;
        end
    end
    
    % % Count total number of sites in folds and twists in the start_sheet
    for i=1:length(start_sheet)
        if start_sheet(i) < 0
            sumtwists_0 = sumtwists_0 + 1;
        elseif start_sheet(i) >= 1
            sumfolds_0 = sumfolds_0 + 1;
        end
    end

    
    % % Identify dynamic features for this perturbation
    
    % % Build displacement matrix
    displ_mat = [];
    for i=1:length(junctions(:,1))
        
        delta_width = 0;
        delta_avg_pos = 0;
        left_boundary_motion= 0;
        right_boundary_motion = 0;
        
        % % Get the width, avg position, and boundaries of this motif
        ftr = junctions(i,3);
        width_0 = junctions(i,2)-junctions(i,1)+1;
        avg_pos_0 = mean(junctions(i,1:2));
        l_boundary_0 = junctions(i,1);
        r_boundary_0 = junctions(i,2);
        
        % % Find the same feature in the perturbed sheet junctions
        ftr_p = 0;
        ftr_p_info = [];
        if isempty(junctions_perturb) == false
            for j=1:length(junctions_perturb(:,1))
                if junctions_perturb(j,3) == ftr
                    ftr_p = junctions_perturb(j,3);
                    ftr_p_info = junctions_perturb(j,:);
                end
            end
        end
        % % Case where this feature is NOT present in junctions_perturb
        if ftr_p == 0 && isempty(ftr_p_info)
            dropped = 1;

            if l_boundary_0 == 1 && r_boundary_0 == 1
                delta_width = 1;
                delta_avg_pos = -1;
                left_boundary_motion = -1;
                right_boundary_motion = -1;
            elseif l_boundary_0 == L && r_boundary_0 == L
                delta_width = 1;
                delta_avg_pos = 1;
                left_boundary_motion = 1;
                right_boundary_motion = 1;
            else
                delta_width = 0;
                delta_avg_pos = 0;
                left_boundary_motion = 0;
                right_boundary_motion = 0;
            end
        % % Case where this feature IS present in junctions_perturb
        else
            dropped = 0;
            
            % % Get the width change for this feature
            width_1 = ftr_p_info(2)-ftr_p_info(1)+1;
            delta_width = width_1 - width_0; 
            % If delta_width > 0, ftr got bigger with perturbation
            % If delta_width < 0, ftr got smaller with perturbation
            % If delta_width= 0, ftr stayed same size with perturbation
            
            % % Get the avg position change for this feature
            avg_pos_1 = mean(ftr_p_info(1:2));
            delta_avg_pos = avg_pos_1 - avg_pos_0;  
            % If delta_avg_pos > 0, moved to right, If delta_avg_pos < 0,
            % moved to left. If delta_avg_pos = 0, it either didn't move or
            % underwent symmetric motion (OUT and IN perturbation)
            
            % % Get the position change for the left boundary of the feature
            left_boundary_motion = ftr_p_info(1) - l_boundary_0;
            % If lbm > 0, left boundary moved to the right in the perturbation
            % If lbm < 0, left boundary moved to the left in the perturbation
            % If lbm = 0, left boundary didn't move in the perturbation
            
            % % Get the position change for the right boundary of the feature
            right_boundary_motion = ftr_p_info(2) - r_boundary_0;
            % If rbm > 0, right boundary moved to the right in the perturbation
            % If rbm < 0, right boundary moved to the left in the perturbation
            % If rbm = 0, right boundary didn't move in the perturbation            
        end
        
        % % Save to displ_mat: [ftr,dropped, width, width change, avg pos change, lbm, rbm, jxn_pair(1), jxn_pair(2)]
        ftr_info = [ftr, dropped, width_0, delta_width, delta_avg_pos, left_boundary_motion, right_boundary_motion,l_boundary_0,r_boundary_0];
        displ_mat(end+1,:) = ftr_info;
    end

    % % Now that information is in displ_mat, assign costs
    
    % % Get fold_motion_cost from asymmetric fold motions in displ_mat
    fold_motion_cost = 0;
    ind1 = displ_mat(:,1) > 0;
    fold_rows_using = [];
    fold_rows = displ_mat(ind1,:);
    if isempty(fold_rows) == false
        ind2 = [fold_rows(:,6) > 0 & fold_rows(:,7) > 0] | [fold_rows(:,6) < 0 & fold_rows(:,7) < 0];
        fold_rows_using = fold_rows(ind2,:);
        
        % % Folds which are one-site wide
        ind3 = fold_rows(:,8) == fold_rows(:,9);
        one_wide_folds = fold_rows(ind3,:);
        if isempty(one_wide_folds) == false
            fold_rows_using = [fold_rows_using;one_wide_folds];
        end
        % % Folds sliding past each other but one edge is at a boundary
        ind4 = [fold_rows(:,6) == 0 & fold_rows(:,7) < 0 & fold_rows(:,8) == 1] | ...
            [fold_rows(:,6) < 0 & fold_rows(:,7) == 0 & fold_rows(:,9) == length(end_sheet)] | ...
            [fold_rows(:,6) == 0 & fold_rows(:,7) > 0 & fold_rows(:,8) == 1] | ...
            [fold_rows(:,6) > 0 & fold_rows(:,7) == 0 & fold_rows(:,9) == length(end_sheet)];
        boundary_folds = fold_rows(ind4,:);
        if isempty(boundary_folds) == false
            fold_rows_using = [fold_rows_using;boundary_folds];
        end
        % % Folds sliding past each other that are right next to each other
        ind5 = [fold_rows(:,6) > 0 & fold_rows(:,7) == 0] | ...
             [fold_rows(:,6) < 0 & fold_rows(:,7) == 0] | ...
             [fold_rows(:,6) == 0 & fold_rows(:,7) > 0] | ...
             [fold_rows(:,6) == 0 & fold_rows(:,7) < 0];
        % % One-sided fold motion due to collision
        one_sided_folds = fold_rows(ind5,:);
        if isempty(one_sided_folds) == false
            fold_rows_using = [fold_rows_using;one_sided_folds];
        end
        
        fold_rows_using = unique(fold_rows_using,'rows');
        if isempty(fold_rows_using) == false
            for i=1:length(fold_rows_using(:,1))
                % % For each fold, fold width * displacement*E_f]
                if abs(fold_rows_using(i,5)) == 0.5
                    fold_rows_using(i,5) = 2;
                end
                cost_per_fold = fold_rows_using(i,3)*abs(fold_rows_using(i,5))*E_f;
                fold_motion_cost = fold_motion_cost + cost_per_fold;
            end
        end
    end    
    
    % % Get twist_motion_cost from all twist motions in displ_mat
    twist_motion_cost = 0;
    ind1 = displ_mat(:,1) < 0;
 
    twist_rows = displ_mat(ind1,:);
    if isempty(twist_rows) == false
        ind2 = twist_rows(:,5) ~= 0;
        twist_rows_using = twist_rows(ind2,:);
        if isempty(twist_rows_using) == false
            for i=1:length(twist_rows_using(:,1))
                % % [for each twist, twist width * displacement*E_f]
                %cost_per_twist = twist_rows_using(i,3)*twist_rows_using(i,5)*E_f;
                cost_per_twist = twist_rows_using(i,3)*abs(twist_rows_using(i,5))*E_f;
                twist_motion_cost = twist_motion_cost + cost_per_twist;
            end
        end
    end
    
    % % Get twist_topology_cost from all twist motions in displ_mat
    twist_topology_cost = 0;
    ind1 = displ_mat(:,1) < 0;
    twist_rows = displ_mat(ind1,:);
    if isempty(twist_rows) == false
        % % Count the twists which expanded or resolved without being kicked out
        ind2 = twist_rows(:,4) ~= 0 & twist_rows(:,2) == 0;
        twist_rows_using = twist_rows(ind2,:);
        if isempty(twist_rows_using) == false
            counter = 0;
            for i=1:length(twist_rows_using(:,1))

                counter = counter + 1;
            end
            if counter > 0
                twist_topology_cost = Inf;
            end
        end
        
        ind3 = twist_rows(:,4) ~= 0 & twist_rows(:,2) == 1;
        twist_rows_using = twist_rows(ind3,:);
        if isempty(twist_rows_using) == false
            counter = 0;
            for i=1:length(twist_rows_using(:,1))
                is_l_boundary = twist_rows_using(i,8) == 1;
                is_r_boundary = twist_rows_using(i,9) == length(end_sheet);
                if is_l_boundary == false && is_r_boundary == false
                    count = counter + 1;
                end
            end
            if counter > 0
                twist_topology_cost = Inf;
            end
        end
    end
    

    % % Get activity contribution from all motions in displ_mat
    activity_contribution = 0;
    ind1 = displ_mat(:,4) ~= 0 | displ_mat(:,5) ~= 0;
    moving_rows = displ_mat(ind1,:);
    
    if isempty(moving_rows) == false
        for i=1:length(moving_rows(:,1))
            % getActivityContribution(activity_vector,1,a_cs,jxn_pair)
            jxn_pair_p = [moving_rows(i,8),moving_rows(i,9)];
            
            if direction ~= 0
                activity_contribution = activity_contribution + getActivityContribution(activity_vector,direction,a_cs,jxn_pair_p,sub_l,sub_r);
            end
        end
    end

    % % Calculate the energy difference of the initial condition and the
    % % perturbed sheet
    energy_ic = sumfolds_0*E_cc + ... % num sites in fold (STATIC COST)
             ( length(start_sheet)-(sumtwists_0+sumfolds_0) )*E_cs + ... % num sites in flat (STATIC COST)
             getBendingEnergy(E, t, length(start_sheet), epsilon, numfolds_0) + ... % num folds (STATIC COST)
             sumtwists_0*E_cc + ... % num sites in twist (STATIC COST)
             numtwist_0 * E_tw;  % num twists (STATIC COST)

    activity_contribution;

    energy_state = sumfolds*E_cc + ... % num sites in fold (STATIC COST)
             ( length(end_sheet)-(sumtwists+sumfolds) )*E_cs + ... % num sites in flat (STATIC COST)
             getBendingEnergy(E, t, length(end_sheet), epsilon, numfolds) + ... % num folds (STATIC COST)
             sumtwists*E_cc + ... % num sites in twist (STATIC COST)
             numtwist * E_tw + ... % num twists (STATIC COST)
             activity_contribution + ... % activity contribution (dir. of change vs. dir. of activity force) (DYNAMIC COST)
             fold_motion_cost + ... % fold motion (breaking cc bonds) (DYNAMIC COST) 
             twist_motion_cost +... % twist motion (breaking cc bonds) (DYNAMIC COST)
             twist_topology_cost; % twist resolution (breaking everything) (DYNAMIC COST)
   
   % % Report the energy difference
   delta_E = energy_state - energy_ic;
end

