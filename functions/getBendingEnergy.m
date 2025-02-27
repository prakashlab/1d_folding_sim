function energy = getBendingEnergy(E, t, L, epsilon, numfolds)
    %%%%%%%%% getBendingEnergy %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Equation for bending energy in a fold. % % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    energy = E*t*L*sqrt(epsilon)*numfolds;
end

