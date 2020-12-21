function EMG_refresh(Img,man_switch)    
    for i = 1:length(man_switch)
        man_switch(i).Visible = 'off';
        man_switch(i).String = 'auto';
        man_switch(i).Value = 0;
    end
    for i = 1:8
       subplot(3,4,i)
       imagesc(Img);
       colormap gray;
       xticklabels([]);
       yticklabels([]);
       man_switch(i).Visible = 'on';
    end
    sgtitle('EMG vs time sample') 
end