function computeActiveEMG(~,~,TimeWin,T1,T2,ScaleF,man_switch,Page,...
                          PageNoText, pagesteps, status_text, refreshImg)
     
    % Extract the current params
    timeWin = floor(TimeWin.Value)+1;
    t1 = floor(T1.Value)+1;
    t2 = floor(T2.Value)+1;
    scaleF = floor(ScaleF.Value)+4;
    
    % Change status to recomputing
    txt = getCurrentStatus(3);
    status_text.String = txt;
    disp(txt{2});
    
    % Change plot panels to 'Refreshing'
    EMG_refresh(refreshImg,man_switch);   
    drawnow;
    
    % Get current EMG data and parameters
    emgdat = guidata(gcf);
    
    % Recompute active periods and update EMG data and parameters
    [Onset, Offset] = active_EMG_auto(emgdat.emg,timeWin,t1,t2,scaleF);
    emgdat.Onset = Onset; emgdat.Offset = Offset;
    emgdat.timeWin = timeWin; emgdat.t1 = t1; emgdat.t2 = t2;
    emgdat.scaleF = scaleF;  
    guidata(gcf,emgdat);
    
    % Refresh plots 
    EMG_plotter(emgdat.emg,Onset,Offset,1,man_switch);
    Page.Value = 0;
    PageNoText.String = ['Page no.: ',num2str(1),'/',num2str(pagesteps(end)+1)];
    
    % Reset status
    txt = getCurrentStatus(1);
    status_text.String = txt;
    disp('Done');
end