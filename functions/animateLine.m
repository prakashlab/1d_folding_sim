function animateLine(sheet_states)
    %%%%%%%%% animateLine %%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Function to make a simple line         % %
    % % animation of a sheet states matrix,    % %
    % % i.e. post-simulation.                  % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % % SET dir for saving images (pre-animation)
    img_Dir = "/Volumes/GoogleDrive/My Drive/prakash_lab_charlotte/tplax_unfolding/unfold_sim/1D_active_twist_energetic_model/plots/to_animate/";
    
    % % SET path for saving final animation 
    write_Dir = '/Volumes/GoogleDrive/My Drive/prakash_lab_charlotte/tplax_unfolding/unfold_sim/1D_active_twist_energetic_model/plots/growthmovie.avi';
    
    % % Generate a plot for each sheet state (row) in sheet_states
    for i=1:length(sheet_states(:,1))
        figure
        coords = [];
        row = sheet_states(i,:);        
        prev_val = row(1);
        block_width = 1;
        x_counter = 0;
        x_coord = 0;
        y_coord = 0;
        
        % % Set dimensions within and between folds
        fold_half_width = 0.5;
        gap_btwn_folds = 0.1;
        
        for j=2:length(row)
            if row(j) == prev_val
                block_width = block_width + 1;
                prev_val = row(j);
            elseif row(j) ~= prev_val
                if prev_val == 0
                    
                    for k=1:block_width
                        x_coord = k + x_counter;
                        y_coord = 0;
                        coords(end+1,:) = [x_coord y_coord];
                    end
                    x_counter = x_counter + block_width;
                elseif prev_val > 0
                    x_coord = x_counter + fold_half_width;
                    y_coord = block_width/2;
                    coords(end+1,:) = [x_coord-fold_half_width 0];
                    coords(end+1,:) = [x_coord-fold_half_width y_coord];
                    coords(end+1,:) = [x_coord y_coord];
                    coords(end+1,:) = [x_coord+fold_half_width y_coord];
                    coords(end+1,:) = [x_coord+fold_half_width 0];
                elseif prev_val < 0
                    x_coord = x_counter + fold_half_width;
                    y_coord = 1;
                    coords(end+1,:) = [x_coord-fold_half_width 0];
                    coords(end+1,:) = [x_coord-fold_half_width y_coord];
                    coords(end+1,:) = [x_coord y_coord];
                    coords(end+1,:) = [x_coord+fold_half_width y_coord];
                    coords(end+1,:) = [x_coord+fold_half_width 0];
                end
                prev_val = row(j);
                block_width = 1;
                x_counter = x_counter + 1+gap_btwn_folds;
            end
        end
        
        if prev_val == 0    
            for k=1:block_width
                x_coord = k + x_counter;
                y_coord = 0;
                coords(end+1,:) = [x_coord y_coord];
            end
            x_counter = x_counter + block_width;
        elseif prev_val > 0
            x_coord = x_counter + fold_half_width;
            y_coord = block_width/2;
            coords(end+1,:) = [x_coord-fold_half_width 0];
            coords(end+1,:) = [x_coord-fold_half_width y_coord];
            coords(end+1,:) = [x_coord y_coord];
            coords(end+1,:) = [x_coord+fold_half_width y_coord];
            coords(end+1,:) = [x_coord+fold_half_width 0];
            x_counter = x_counter + fold_half_width;
        elseif prev_val < 0
            x_coord = x_counter + fold_half_width;
            y_coord = 1;
            coords(end+1,:) = [x_coord-fold_half_width 0];
            coords(end+1,:) = [x_coord-fold_half_width y_coord];
            coords(end+1,:) = [x_coord y_coord];
            coords(end+1,:) = [x_coord+fold_half_width y_coord];
            coords(end+1,:) = [x_coord+fold_half_width 0];
            x_counter = x_counter + fold_half_width;
        end
        

        coords = sortrows(coords,1);
        line(coords(:,1),coords(:,2),'LineWidth',1.5)
        ylim([0 length(row)/2])
        xlim([0 length(row)])
        %axis off
%         set(gca,'YTick',[]);
%         set(gca,'XTick',[]);

        % % Save individual plot to img_dir
        A = gcf;
        exportgraphics(A,img_Dir+i+".png",'Resolution',300)
        close 
    end
    
    
    % % Get the plots from img_dir and make an animation from them
    myFiles = dir(fullfile(img_Dir,'*.png'));
    images = cell(length(myFiles),1);

    % % Order the plots in time
    ordered_strings = [];
    indxs = [];
    for i=1:length(myFiles)
        name = myFiles(i).name;
        a = split(name, ".");
        num = string(a(1));
        indxs(end+1) = num;
    end

    counter = 1;
    for i=1:length(myFiles)
        for j=1:length(indxs)
            if indxs(j) == counter
                ordered_strings(end+1) = j;
            end
        end
        counter = counter + 1;
    end

    for i=1:length(myFiles)
        fullFileName = myFiles(ordered_strings(i)).folder+"/"+myFiles(ordered_strings(i)).name;
        images{i} = imread(fullFileName); 
    end

    % % Save animation movie as avi to save dir
    writerObj = VideoWriter(write_Dir);
    writerObj.FrameRate = 1;

    open(writerObj);

    for u=1:length(myFiles)
        writeVideo(writerObj, images{u})
    end
    close(writerObj);

end

