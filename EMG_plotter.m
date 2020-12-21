% Plot EMGs with computed onset and offset times (8 per page)
function EMG_plotter(emg,Onset,Offset,pageNo,man_switch)
    start = (pageNo - 1) * 8 + 1;
    k = 1;
    
    for i = 1:length(man_switch)
        man_switch(i).Visible = 'off';
    end
    for i = start:(start+7)
       subplot(3,4,k)
       if i <= size(emg,2)
           plot(emg(:,i))
           hold on
           plot(Onset(i)*ones(1,2),[0 max(emg(:,i))],'LineWidth',2,'Color','r');
           plot(Offset(i)*ones(1,2),[0 max(emg(:,i))],'LineWidth',2,'Color','r');
           xvals = Onset(i):Offset(i);
           plot(xvals,max(emg(:,i))*ones(1,length(xvals)),'LineWidth',2,'Color','r');     
           xticklabels([]);
           yticklabels([]);
           grid on;
           hold off;
           k = k + 1;
           
           man_switch(i).Visible = 'on';
       else
           plot(0.5,0.5)
           xlim([0 1]); ylim([0 1])
           text(0.4,0.5,'NA','FontSize',24);
           k = k + 1;
           xticklabels([]);
           yticklabels([]);
       end
    end
    sgtitle('EMG vs time sample') 
end