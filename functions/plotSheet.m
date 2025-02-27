function plotSheet(sheet_states,energy_vs_time,activity_states,fold_ids,twist_ids,savefile,savedir)
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
    ax1 = subplot(1,3,1);
    plot(energy_vs_time(:,1)-1, energy_vs_time(:,2),'-k','LineWidth',1.5)
    hold on
    scatter(energy_vs_time(:,1)-1, energy_vs_time(:,2),'filled','k')
    xlabel("Time")
    ylabel("Static Energy")
    pbaspect([1 1 1])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Plot activity state vs. time as a kymograph
    ax2 = subplot(1,3,2);
    L = length(activity_states(1,:));
    % % Extend array because pcolor cuts a row and col
    [w, h] = size(activity_states);
    tmparr = activity_states;
    tmparr(end+1,:)=zeros(1,L);
    tmparr(:,end+1)=zeros(w+1,1);
    pcolor(tmparr)
    
    % % Set colors for activity orientations
    mymap = [];
    orientation_colors = [245, 66, 66; %red 
                          255, 255, 255; %grey
                          23, 179, 9]; %green
                      
    orientation_ids = sort(unique(activity_states));
    for i=1:length(orientation_ids)
        if orientation_ids(i) == -1
            mymap = [mymap;orientation_colors(3,:)];
        elseif orientation_ids(i) == 0
            mymap = [mymap;orientation_colors(2,:)];
        elseif orientation_ids(i) == 1
            mymap = [mymap;orientation_colors(1,:)];
        end
    end
    
    mymap = mymap/255;
     
    colormap(ax2,mymap)

    grid off;
    axis equal;
    ax = gca;
    ax.LineWidth = 2;
    ax.GridAlpha = 1;
    set(gca,'XTickLabel',[]);
    ylabel("<-- Time")
    xlabel("Activity lattice")
    set(gca, 'YDir','reverse')
    ylim([1 w+1])
    xlim([1 h+1])

    cbh = colorbar ; %Create Colorbar
    
    legend = ["Left","Fold/Twist","Right"];
    set(cbh,'YTick',-1:1:1) 
    cbh.TickLabels = legend;
    hold on
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Plot sheet state vs. time as a kymograph
    ax3 = subplot(1,3,3);
    L = length(sheet_states(1,:));
    % % Extend array because pcolor cuts a row and col
    [w, h] = size(sheet_states);
    tmparr = sheet_states;
    tmparr(end+1,:)=zeros(1,L);
    tmparr(:,end+1)=zeros(w+1,1);
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

    twistcolor = [255 131 18];
    
    flatcolor = [186, 184, 184];
    
    foldcolors = [54 137 255;
                65 227 235;
                49 160 212;
                49 212 174;
                55 238 143;
                255, 196, 196;
                255, 223, 189;
                242, 206, 222;
                203, 199, 221]; 

    for i=1:num_twists
        mymap(end+1,:) = twistcolor;
    end
    mymap(end+1,:) = flatcolor;
    
    for i=1:num_folds
        if i <= 9
            mymap(end+1,:) = foldcolors(i,:);
        else
            mymap(end+1,:) = foldcolors(1,:);
        end
    end

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

    cbh = colorbar ;
    
    % % Make tick labels for unique folds and twists
    all_ids = horzcat(twist_ids,fold_ids);
    all_ids(end+1) = 0;
    cbh_low = min(all_ids);
    cbh_high = max(all_ids);

    tl = "";
    if isempty(twist_ids) == false
        for i=1:length(twist_ids)
            tl = tl+"Twist "+string(i) + ".";
        end
    end
    tl = tl+"Flat.";
    if isempty(fold_ids) == false
        for i=1:length(fold_ids)
            if i~= length(fold_ids)
                tl = tl+"Fold "+string(i) + ".";
            else
                tl = tl+"Fold "+string(i);
            end
        end
    end
    lab = split(tl,".");
    set(cbh,'YTick',cbh_low:1:cbh_high)
    cbh.TickLabels = split(tl,".");
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % % Save file with parameters in filename
    if savefile == true
        parameters
        filename = string(datetime('now'))+"_Ecs"+string(params.E_cs)+"_Ecc"+string(params.E_cc)+"_Acs"+string(params.a_cs)+"_"+params.case_id;
        savefig(savedir+filename+'.fig')
        saveas(gca,savedir+filename+'.pdf')
        A = gcf;
        exportgraphics(A,savedir+filename+'.png','Resolution',300)
        close
    end
end

