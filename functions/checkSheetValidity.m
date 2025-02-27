function validSheet = checkSheetValidity(sheet_ic, sheet_end)
    %%%%%%%%% checkSheetValidity %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Function to check whether a sheet is   % % 
    % % valid (follows assumptions and rules   % %  
    % % of the simulation) based on the        % %
    % % initial condition. For example, a fold % % 
    % % ID must be a contiguous patch and cant % % 
    % % be intercalated with another motif.    % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % % Assume this is a valid sheet
    validSheet = true;
    
    % % Get junction mat for this sheet
    junctions = getJunctionList(sheet_end);
    
    if isempty(junctions) == false
        % % 1. Check for intercalated/overlapping folding motifs
        for i=1:length(junctions(:,1))
            l_boundaryA = junctions(i,1);
            r_boundaryA = junctions(i,2);
            A_sites = linspace(l_boundaryA,r_boundaryA,r_boundaryA-l_boundaryA+1);
            for j=1:length(junctions(:,1))
                if i ~= j
                    l_boundaryB = junctions(j,1);
                    r_boundaryB = junctions(j,2);
                    B_sites = linspace(l_boundaryB,r_boundaryB,r_boundaryB-l_boundaryB+1);
                    % % Check if these two junctions overlap
                    overlap = intersect(A_sites,B_sites);
                    if isempty(overlap) == false
                        validSheet = false;
                    end
                end
            end
        end

        % % 2. Check for 0s in the middle of a feature
        for i=1:length(junctions(:,1))
            l_boundary = junctions(i,1);
            r_boundary = junctions(i,2);
            for j= l_boundary:r_boundary
                if sheet_end(j) == 0
                    validSheet = false;
                end
            end
        end
        
        % % 3. Check that a twist did not magically disappear without being
        % % kicked out of the sheet
        ic_l_boundary_twist = sheet_ic(1);
        ic_r_boundary_twist = sheet_ic(length(sheet_ic));
                
        kicked_out_l = true;
        kicked_out_r = true;
        
        ic_twist_ids = [];
        for i=1:length(sheet_ic)
            if sheet_ic(i) < 0
                ic_twist_ids(end+1) = sheet_ic(i);
            end
        end
        ic_twist_ids = unique(ic_twist_ids);
        
        end_twist_ids = [];
        for i=1:length(sheet_end)
            if sheet_end(i) < 0
                end_twist_ids(end+1) = sheet_end(i);
            end
        end
        end_twist_ids = unique(end_twist_ids);
                
        lost_twists = setdiff(ic_twist_ids,end_twist_ids);
        
        if isempty(lost_twists) == false
            for i=1:length(lost_twists)
                kicked_out_l = lost_twists(i) == ic_l_boundary_twist;
                kicked_out_r = lost_twists(i) == ic_r_boundary_twist;
            end
        end
        if kicked_out_l==false && kicked_out_r == false
            validSheet = false;
        end
    end 
end

