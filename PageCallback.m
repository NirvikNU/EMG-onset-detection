function PageCallback(src,~,PageNoText,pagesteps,man_switch)
    
    % Get EMG data
    emgdat = guidata(gcf);
    
    % Get current page no. and update in 'emgdat'
    cpage = find(pagesteps == (floor(src.Value)));
    emgdat.currentPage = cpage-1;
    guidata(gcf,emgdat);
    
    % Plot EMGs of current page no. 
    EMG_plotter(emgdat.emg,emgdat.Onset,emgdat.Offset,cpage,man_switch);
    
    % Update page no. text
    PageNoText.String = ['Page no.: ',num2str(cpage),'/',num2str(pagesteps(end)+1)];
    
end