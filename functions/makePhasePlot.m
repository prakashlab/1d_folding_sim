function [outputArg1,outputArg2] = makePhasePlot(savedir, arr, xlabeltxt,ylabeltxt, colorbarlabel,type,savefileid,xaxis_list,yaxis_list)
    %%%%%%%%% makePhasePlot %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % This function generates a phase plot   % % 
    % % and is intended to be called at the    % %  
    % % end of run_param_sweep.m. Any matrix   % % 
    % % can be passed in with any 2 parameter  % % 
    % % names. savedir set in run_param_sweep  % %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    
    % % Build final state phase plot
    figure
    L = length(arr(1,:));
    [w, h] = size(arr);
    tmparr = arr;
    tmparr(end+1,:)=zeros(1,L);
    tmparr(:,end+1)=zeros(w+1,1);
    x = pcolor(tmparr)
    %x.FaceColor = 'interp';
    
    % % Set colormap
    colormap(slanCM('gem'))
    a = colorbar;
    a.Label.String = colorbarlabel;
    
    set(x,'FaceAlpha',0.9)

    grid off;
    axis equal;
    ax = gca;
    ax.LineWidth = 2;
    ax.GridAlpha = 1;
    
    tickvals = round(xaxis_list,2);
    xticklist =[1.5:length(xaxis_list)+0.5];
    set(gca,'XTick',xticklist)
    set(gca,'XTickLabel',tickvals)
    
    tickvals = round(yaxis_list,2);
    yticklist =[1.5:length(yaxis_list)+0.5];
    set(gca,'YTick',yticklist)
    set(gca,'YTickLabel',tickvals)
    
    if type == "folding"
        caxis(ax, [0 1])
    end
    
    if type == "time"
       caxis(ax,[0 50])
    end

    % % Set axis labels
    xlabel(xlabeltxt)
    ylabel(ylabeltxt)
    


    % % Set axis limits
    ylim([1 w+1])
    xlim([1 h+1])
    
    set(gca,'fontsize', 14)
    


    % % Save file with parameters and mat type in filename
    filename = xlabeltxt+"_"+ylabeltxt + "_"+type;
    filename = "";
    savefig(savedir+filename+savefileid+'.fig')
    saveas(gca,savedir+filename+savefileid+'.pdf')
    A = gcf;
    exportgraphics(A,savedir+filename+savefileid+type+ '.png','Resolution',300)
    close

end

