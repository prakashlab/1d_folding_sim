function [outcome, time] = runSimulation(params)
    %%%%%%%%% runSimulation %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This is the main function for running  % % 
    % % unfold sim. First run parameters to    % %  
    % % generate params. Alternatively, use    % % 
    % % run_param_sweep or unit_testing to run % % 
    % % many simulations in a loop.            % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    % % Get and rename parameters from input params struct
    sheet = params.sheet;
    savefile = params.savefile;
    E_cc = params.E_cc;
    E_cs = params.E_cs;
    a_cs = params.a_cs;
    a_rand = params.a_rand;
    E_f = params.E_f;
    E_tw = params.E_tw;
    nucl_prob = params.nucl_prob;
    case_id = params.case_id;
    flocking_coherence_time = params.flocking_coherence_time;
    savedir = params.savedir;
    E = params.E;
    t = params.t;
    L = params.L;
    epsilon = params.epsilon;
    delta = params.delta;
    lbc = params.lbc;
    fold_ids = params.fold_ids;
    twist_ids = params.twist_ids;
    manual_cutoff = params.manual_cutoff;
    flocking_mode = params.flocking_mode;
    
    

    % % Initialize variables needed for time evolution loop
    sheet_evo = sheet; % stores prev time sheet state
    sheet_states = []; % stores all sheet states at all timesteps
    sheet_states(1,:) = sheet; % set first sheet state to initial condition
    activity_states = []; % stores all activity states at all timesteps
    counter = 2; % number of states at end of time step
    evo_done = false; % is evolution done or not
    energy_vs_time = []; % stores static sheet energies in time
    random_choice1 = true; % was initial energy comparison btwn sheets random
    random_choice2 = false; % was resolve conflicts energy comparison btwn sheets random
    activity_vector = []; % stores current activity state
    ten_sheet_memory = []; % stores past 10 sheet states, to determine steady state
    
    % % Get the list of non-flat junctions in the sheet
    junctions = getJunctionList(sheet_evo);
    
    % % Record the static energy of the initial condition (time point 1)
    energy_vs_time(end+1,:) = [1,checkStaticEnergy(sheet_evo,params)];
    

    % % Run time evolution loop
    while evo_done == false
        
        % % Find junctions for local perturbation
        junctions = getJunctionList(sheet_evo);

        % % Initialize activity vector for this timestep
        [activity_vector, activity_jxns] = initActivityVector(junctions,sheet_evo,flocking_coherence_time,flocking_mode,counter,activity_vector);

        % % Save the activity state for this timestep
        if a_cs ~= 0
            activity_states= [activity_states;activity_vector];
        else
            activity_states= [activity_states;zeros(1,length(activity_vector))];
        end
        
        % % Initialize sheet_tmp as variable to modify
        sheet_tmp = sheet_evo;

        % % Check if there are any folded/twisted regions to perturb
        if isempty(junctions) == false
            sheet_tmp_list = []; % List to hold result of local perturbation for each folding motif
            sheet_tmp_list = [sheet_tmp_list;sheet_evo];
            state_lookup = [];


            % % Loop through junctions and try local perturbation for each one
            for i=1:length(junctions(:,1))

                jxn_pair = junctions(i,:);

                % % Get possible sheet states for this fold in this timestep
                % % sheet_tmp_<which junction>_<which direction is it
                % % moving>:

                % % 1. Both junctions moving
                sheet_tmp_both_out = perturbSheet(sheet_evo,1,jxn_pair,junctions); %1
                sheet_tmp_both_in = perturbSheet(sheet_evo,2,jxn_pair,junctions); %2
                sheet_tmp_both_right = perturbSheet(sheet_evo,3,jxn_pair,junctions); %3
                sheet_tmp_both_left = perturbSheet(sheet_evo,4,jxn_pair,junctions); %4

                % % 2. Only one junction moving (only relevant when motif width > 1)
                if jxn_pair(1) - jxn_pair(2) ~= 0
                    sheet_tmp_right_right = perturbSheet(sheet_evo,5,jxn_pair,junctions); %5
                    sheet_tmp_right_left = perturbSheet(sheet_evo,6,jxn_pair,junctions); %6
                    sheet_tmp_left_right = perturbSheet(sheet_evo,7,jxn_pair,junctions); %7
                    sheet_tmp_left_left = perturbSheet(sheet_evo,8,jxn_pair,junctions); %8
                else
                    sheet_tmp_right_right = sheet_tmp_both_right;
                    sheet_tmp_right_left = sheet_tmp_both_left;
                    sheet_tmp_left_right = sheet_tmp_both_right;
                    sheet_tmp_left_left = sheet_tmp_right_left;
                end


                % % Get energies for the possible states above
                if jxn_pair(2) - jxn_pair(1) + 1 ~= L
                    E_sheet_both_out = checkDeltaEnergy(sheet_evo,sheet_tmp_both_out,1,junctions,activity_vector,1,L,params);
                else
                    E_sheet_both_out = Inf;
                end
                if jxn_pair >=0
                    E_sheet_both_in = checkDeltaEnergy(sheet_evo,sheet_tmp_both_in,2,junctions,activity_vector,1,L,params);
                else
                    E_sheet_both_in = Inf;
                end
                E_sheet_both_right = checkDeltaEnergy(sheet_evo,sheet_tmp_both_right,3,junctions,activity_vector,1,L,params);
                E_sheet_both_left = checkDeltaEnergy(sheet_evo,sheet_tmp_both_left,4,junctions,activity_vector,1,L,params);

                E_sheet_right_right = checkDeltaEnergy(sheet_evo,sheet_tmp_right_right,5,junctions,activity_vector,1,L,params);
                E_sheet_right_left = checkDeltaEnergy(sheet_evo,sheet_tmp_right_left,6,junctions,activity_vector,1,L,params);
                E_sheet_left_right = checkDeltaEnergy(sheet_evo,sheet_tmp_left_right,7,junctions,activity_vector,1,L,params);
                E_sheet_left_left = checkDeltaEnergy(sheet_evo,sheet_tmp_left_left,8,junctions,activity_vector,1,L,params);

                if jxn_pair(3) < 0
                    E_sheet_both_out = Inf;
                    E_sheet_both_in = Inf;
                    E_sheet_right_right = Inf;
                    E_sheet_right_left = Inf;
                    E_sheet_left_right = Inf;
                    E_sheet_left_left = Inf;  
                end

                Energies = [E_sheet_both_out, 
                            E_sheet_both_in, 
                            E_sheet_both_right, 
                            E_sheet_both_left, 
                            E_sheet_right_right,
                            E_sheet_right_left,
                            E_sheet_left_right,
                            E_sheet_left_left,
                            0];
                        
                % % Choose the state with the minimal energy
                [sheet_tmp,random_choice1] = compareEnergies(Energies,[sheet_tmp_both_out;sheet_tmp_both_in;sheet_tmp_both_right;sheet_tmp_both_left;sheet_tmp_right_right;sheet_tmp_right_left;sheet_tmp_left_right;sheet_tmp_left_left;sheet_evo]);
                sheet_tmp_list = [sheet_tmp_list;sheet_tmp];

                % % Save which jxn was perturbed in this state
                state_lookup(end+1,:) = [i+1,jxn_pair(3)];
            end

            % % After looping over all junctions, merge the i perturbed sheets into one sheet, 
            % % resolve any conflicts that came up between different junctions
            [sheet_tmp,random_choice2] = resolveConflicts(sheet_tmp_list,state_lookup,activity_vector,params);

        end

        % % Decide whether to nucleate new folds at this timestep
        sheet_tmp = nucleateFolds(sheet_tmp, activity_vector, activity_jxns, junctions, nucl_prob,a_cs,flocking_coherence_time,flocking_mode);



        % % Update sheet and save iteration for later plotting
        sheet_0 = sheet_evo;
        sheet_evo = sheet_tmp;
        sheet_states= [sheet_states;sheet_evo];
        
        % % Update simulation memory of 10 most recent sheet states
        mem_size = size(ten_sheet_memory);
        if mem_size(1) >= 10
            ten_sheet_memory = ten_sheet_memory(2:10,:);
        end
        
        ten_sheet_memory = [ten_sheet_memory;sheet_evo];
        
        energy_vs_time(end+1,:) = [counter,checkStaticEnergy(sheet_evo,params)];

        % % Update time counter
        counter = counter + 1;

        % % Check if the evolution loop should be stopped
        evo_done = stopEvolution(sheet_0,sheet_evo,counter,random_choice1,random_choice2,manual_cutoff,ten_sheet_memory);
    end
    
    % % Get the final activity state
    if a_cs ~= 0
        activity_states= [activity_states;activity_vector];
    else
        activity_states= [activity_states;zeros(1,length(activity_vector))];
    end

    % % Report the folding outcome and time, for phase plotting
    outcome = sum(sheet_evo(sheet_evo~=0) ~= 0) / length(sheet_evo);
    time = counter;
    
    % % Plot state evolution and energy
    plotSheet_forFigures(sheet_states,energy_vs_time,activity_states,fold_ids,twist_ids, savefile,savedir,"recent",true,false)
end

