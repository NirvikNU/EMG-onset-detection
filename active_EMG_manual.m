
function active_EMG_manual(src,~,status_text)

    % Display status
    txt = getCurrentStatus(2);
    status_text.String = txt;

    % Get EMG data and chosen epoch no.
    emgdat = guidata(gcf);
    cXpos = find(emgdat.xpos == src.Position(1));
    cYpos = find(emgdat.ypos == src.Position(2));
    epochNo = emgdat.currentPage * 8 + (cYpos - 1) * 4 + cXpos;
        
    % Demean signal
    emgdat.emg(:,epochNo) = emgdat.emg(:,epochNo) - mean(emgdat.emg(:,epochNo));
    
    %Plot signal and get manual onset and offset points
    cf = figure;
    userchk = 0;
    while userchk == 0
        subplot('Position',[0.1 0.2 0.8 0.7]); 
        plot(emgdat.emg(:,epochNo));
        xticklabels([]);
        yticklabels([]);
        hold on;
        title('Click to choose ONSET point...','FontSize',16);
        [xval,~] = ginput(1);
        emgdat.Onset(epochNo) = int64(xval);
        xline(xval,'LineWidth',2,'Color','r');
        title('Click to choose OFFSET point...','FontSize',16);
        [xval,~] = ginput(1);
        emgdat.Offset(epochNo) = int64(xval);
        xline(xval,'LineWidth',2,'Color','r');
        str = 'XX';
        while ~strcmpi(str,'Y') && ~strcmpi(str,'N')
            prompt = 'Are you sure? y/n: ';
            str = inputdlg(prompt,'s');
            if strcmpi(str,'Y')
                userchk = 1;
            end
        end
    end
    close(cf);
    
    % Plot data with new onset and offset points
    subplot(3,4,mod(epochNo,8))
    plot(emgdat.emg(:,epochNo));
    hold on
    plot(emgdat.Onset(epochNo)*ones(1,2),[0 max(emgdat.emg(:,epochNo))],'LineWidth',2,'Color','r');
    plot(emgdat.Offset(epochNo)*ones(1,2),[0 max(emgdat.emg(:,epochNo))],'LineWidth',2,'Color','r');
    xvals = emgdat.Onset(epochNo):emgdat.Offset(epochNo);
    plot(xvals,max(emgdat.emg(:,epochNo))*ones(1,length(xvals)),'LineWidth',2,'Color','r');     
    xticklabels([]);
    yticklabels([]);
    grid on;
    hold off;    
    
    % Updata offset and onset points
    guidata(gcf,emgdat);
    
    % Reset radio button and change marker string to 'manual'
    src.Value = 0;
    src.String = 'manual';
    src.FontWeight = 'bold';
    
    % Restore status
    txt = getCurrentStatus(1);
    status_text.String = txt;
end