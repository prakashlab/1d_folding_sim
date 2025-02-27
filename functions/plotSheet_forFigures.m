function plotSheet_forFigures(sheet_states,energy_vs_time,activity_states,fold_ids,twist_ids,savefile,savedir,savename,savemats,comment)
    %%%%%%%%% plotSheet %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function generates 3 summary      % %
    % % plots at the end of the simulation:    % %
    % % 1. static energy vs. time              % %
    % % 2. sheet state vs. time (kymograph)    % %
    % % 3. activity state vs. time (kymograph) % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % % Get fold id's for sheet, since new folds may have nucleated
    fold_ids = unique(sheet_states);
    fold_ids(fold_ids==0) = [];
    fold_ids(fold_ids<0) = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Plot static sheet energy vs. time
    ax1 = subplot(1,1,1);
    plot(energy_vs_time(:,1)-1, energy_vs_time(:,2),'-k','LineWidth',1.5)
    hold on
    scatter(energy_vs_time(:,1)-1, energy_vs_time(:,2),'filled','k')
    xlabel("Time")
    ylabel("Static Energy")
    pbaspect([1 1 1])

    A = gcf;
    exportgraphics(A,savedir+savename+'_energy.png','Resolution',300)
    close
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Plot sheet state vs. time as a kymograph
    ax3 = subplot(1,1,1);

    L = length(sheet_states(1,:));
    % % Extend array because pcolor cuts a row and col
    [w, h] = size(sheet_states);
    tmparr = sheet_states;

    
    for i=1:length(activity_states(:,1))
        for j=1:length(activity_states(1,:))
            if activity_states(i,j) == 1 && sheet_states(i,j) == 0
                tmparr(i,j) = 10000;
            end
            
            if activity_states(i,j) == -1 && sheet_states(i,j) == 0
                tmparr(i,j) = -10000;
            end
        end
    end
    
    tmparr(end+1,:)=zeros(1,L);
    tmparr(:,end+1)=zeros(w+1,1);
    %tmparr(:,end+1)=zeros(w+1,1);
    
    for i=1:length(tmparr(:,1))
        for j=1:length(tmparr(1,:))
            if tmparr(i,j) == 0
                tmparr(i,j) = -10000; %10000
            end
        end
    end
    
    pcolor(tmparr)
    
    
    % % Set colors for unique folds and twist
    mymap = [];
    
    ftrs = unique(sheet_states);
    num_twists = 0;
    num_folds = 0;
    for i=1:length(ftrs)
        if ftrs(i) < 0 
            num_twists = num_twists + 1;
        elseif ftrs(i) > 0 
            num_folds = num_folds + 1;
        end
    end

    
    flatcolor_right = [186 184 184];
    flatcolor_left = [103 107 107];
    

    foldcolors = [133 211 237];


    if comment == false
        mymap(end+1,:) = flatcolor_left;
    end
        
    for i=1:num_twists
        disp("twist")
        mymap(end+1,:) = twistcolor;
    end
    
    
    
    for i=1:num_folds
        disp("fold")
        mymap(end+1,:) = foldcolors(1,:);
    end
    
    mymap(end+1,:) = flatcolor_right;
    
    
    mymap = mymap/255;
    
    colormap(ax3,mymap)

    grid off;
    axis equal;
    ax = gca;
    ax.LineWidth = 2;
    ax.GridAlpha = 1;
    set(gca,'XTickLabel',[]);
    ylabel("<-- Time")
    xlabel("Sheet lattice")
    set(gca, 'YDir','reverse')
    ylim([1 w+1])
    xlim([1 h+1])

    %cbh = colorbar ;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % % Save file with parameters in filename
    if savefile == true
        parameters
        filename = string(datetime('now'))+"_Ecs"+string(params.E_cs)+"_Ecc"+string(params.E_cc)+"_Acs"+string(params.a_cs)+"_"+params.case_id;

        A = gcf;
        exportgraphics(A,savedir+savename+'.png','Resolution',300)
        close
    end
    if savemats == true
        save(savedir+savename+"_activity_states.mat",'activity_states')
        save(savedir+savename+"_sheet_states.mat",'sheet_states')
        save(savedir+savename+"_energy_v_time.mat",'energy_vs_time')
    end
end

