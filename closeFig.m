function closeFig(~,~,minsize)
        
    % Generate the active period EMGs of minsize lenght
    emg_data = guidata(gcf);
    emg_active = zeros(minsize,1);
    emg = emg_data.emg;
    Onset = emg_data.Onset;
    Offset = emg_data.Offset;
    k = 1;
    for i = 1:size(emg,2)
        if ~isnan(Onset(i)) && ~isnan(Offset(i))
            xval = emg(Onset(i):Offset(i),i);
            if length(xval) >= minsize
                emg_active(:,k) = xval(1:minsize) - mean(xval);
                k = k + 1;
            end
        end
    end
    
    % Save the current emgdata in the parent function's workspace
    assignin('caller','emg_active',emg_active);
    
    % close the figure
    close(gcf);
    disp('Active epoch periods saved in ''emg_active'' variable.');
end