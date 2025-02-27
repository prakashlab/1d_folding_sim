function static_energy = checkStaticEnergy(sheet_static,params)
    %%%%%%%%% checkStaticEnergy %%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Function to check the "static" energy  % %
    % % of a sheet. Uses the same energy eq.   % %
    % % from checkDeltaEnergy, but without the % %
    % % costs for asymmetric motion / activity % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % % Load parameters
    E_cc = params.E_cc;
    E_cs = params.E_cs;
    E= params.E;
    t= params.t;
    L= params.L;
    epsilon= params.epsilon;
    E_tw = params.E_tw;
    
    % % Check for static features in the sheet
    numfolds = 0;
    numtwists = 0;
    sumtwists = 0;
    sumfolds = 0;
    
    % % Get the total number of twists and folds
    ftrs = unique(sheet_static);
    for i=1:length(ftrs)
        if ftrs(i) < 0
            numtwists = numtwists + 1;
        elseif ftrs(i) > 0
            numfolds = numfolds + 1;
        end
    end
    
    % % Get the total number of cells participating in twists and folds
    for i=1:length(sheet_static)
        if sheet_static(i) < 0
            sumtwists = sumtwists + 1;
        elseif sheet_static(i) > 0
            sumfolds = sumfolds + 1;
        end
    end
    
    % % Calculate the static energy
    static_energy = sumfolds*E_cc + ... % num sites in fold (STATIC COST)
             ( L-(sumtwists+sumfolds) )*E_cs + ... % num sites in flat (STATIC COST)
             getBendingEnergy(E, t, L, epsilon, numfolds) + ... % num folds (STATIC COST)
             sumtwists*E_cc + ... % num sites in twist (STATIC COST)
             numtwists * E_tw;  % num twists (STATIC COST)
end

