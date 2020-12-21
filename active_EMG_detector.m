% This function computes the onset and offset times of EMG signals
% based on the following publication:
% Dapeng Yang, Huajie Zhang, Yikun Gu, Hong Liu,
% Accurate EMG onset detection in pathological, weak and noisy myoelectric
% signals. Biomedical Signal Processing and Control, Volume 33, 2017, 
% Pages 306-315, https://doi.org/10.1016/j.bspc.2016.12.014.
% (http://www.sciencedirect.com/science/article/pii/S1746809416302269)
% This GUI interface also allows for manual correction and tuning of
% parameters of the automated algorithm
% INPUTS: See active_EMG_auto.m for details of inputs
% EXAMPLE:  fake_EMG = rand(1000,100);
%           active_EMG = active_EMG_detector(fake_EMG,100,100,500,8,1000);
% OUPUT: emg_active  = [Time samples vs. epochs] of active EMG periods
% AUTHOR: NIRVIK SINHA

function emg_active = active_EMG_detector(emg,timeWin,t1,t2,scaleF,minsize)

    % Compute active EMG periods using EMG_onset_auto.m
    disp('Computing active periods, please wait...')
    [Onset, Offset] = active_EMG_auto(emg,timeWin,t1,t2,scaleF);
    emgdat = struct; emgdat.currentPage = 0;
    emgdat.emg = emg; emgdat.Onset = Onset; emgdat.Offset = Offset;
    emgdat.timeWin = timeWin; emgdat.t1 = t1; emgdat.t2 = t2;
    emgdat.scaleF = scaleF;
    
    f = figure('units','normalized','outerposition',[0 0 1 1]);

    % Store emgdata in current figure object
    guidata(f,emgdat);
    emg_active = [];
    
    % Status display
    txt = getCurrentStatus(1);
    status_text = uicontrol(f,'Style','text','String',txt,...
                            'HorizontalAlignment','left',...
                            'Units','normalized','Position',[0.64,0.05,0.4,0.3],...
                            'FontSize',18);     
    
    % Manual switches
    man_switch = gobjects(1,size(emg,2));
    xpos = repmat([0.2 0.4 0.6 0.8 0.2 0.4 0.6 0.8],1,ceil(size(emg,2)/8));
    ypos = repmat([0.65 0.65 0.65 0.65 0.35 0.35 0.35 0.35],1,ceil(size(emg,2)/8));
    emgdat = guidata(f);
    emgdat.xpos = [0.2 0.4 0.6 0.8];
    emgdat.ypos = [0.65 0.35];
    guidata(f,emgdat);
    for i = 1:length(man_switch)
        man_switch(i) = uicontrol(f,'Style','radiobutton','String','auto','Visible','off',...
                                  'Units','normalized','Position',[xpos(i),ypos(i),0.05,0.05]);  
        man_switch(i).Callback = {@active_EMG_manual,status_text};
    end
    
    % Plot the first page
    EMG_plotter(emg,Onset,Offset,1,man_switch);                                        
    
    % Page no. slider
    pagesteps = 0:(ceil(size(emg,2)/8) - 1);
    Page = uicontrol(f,'Style','slider','Min',0,'Max',pagesteps(end),...
                     'SliderStep',[1/pagesteps(end) 1/pagesteps(end)],...
                     'Units','normalized','Position',[0.25,0.1,0.32,0.04]);
    PageNoText = uicontrol(f,'Style','text','FontSize',18,...
                           'String',['Page no.: ',num2str(1),'/',num2str(pagesteps(end)+1)],...
                           'Units','normalized','Position',[0.36,0.14,0.12,0.05]);
    Page.Callback = {@PageCallback,PageNoText,pagesteps,man_switch};
    
    % Sliders for auto-detection parameters
    % Time window slider and text
    TimeWin = uicontrol(f,'Style','slider','Min',0,'Max',size(emg,1)-1,'ForegroundColor','b',...
                        'SliderStep',[1/(size(emg,1)-1) 1/(size(emg,1)-1)],...
                        'Units','normalized','Position',[0.05,0.25,0.125,0.04],'Value',timeWin);
    TimeWinText = uicontrol(f,'Style','text','FontSize',18,...
                            'String',['TimeWin: ',num2str(TimeWin.Value)],...
                            'Units','normalized','Position',[0.065,0.29,0.1,0.05]);
    TimeWin.Callback = {@AlgoParamCallback,TimeWinText,'TimeWin',1};
     
    % t1 slider and text
    T1 = uicontrol(f,'Style','slider','Min',0,'Max',(size(emg,1)-1),'ForegroundColor','b',...
                   'SliderStep',[1/(size(emg,1)-1) 1/(size(emg,1)-1)],...
                   'Units','normalized','Position',[0.2,0.25,0.125,0.04],'Value',t1);
    T1Text = uicontrol(f,'Style','text','FontSize',18,...
                       'String',['t1: ',num2str(T1.Value)],...
                       'Units','normalized','Position',[0.215,0.29,0.1,0.05]);
    T1.Callback = {@AlgoParamCallback,T1Text,'t1',1};
    
    % t2 slider and text
    T2 = uicontrol(f,'Style','slider','Min',0,'Max',(size(emg,1)-1),'ForegroundColor','b',...
                   'SliderStep',[1/(size(emg,1)-1) 1/(size(emg,1)-1)],...
                   'Units','normalized','Position',[0.35,0.25,0.125,0.04],'Value',t2);
    T2Text = uicontrol(f,'Style','text','FontSize',18,...
                       'String',['t2: ',num2str(T2.Value)],...
                       'Units','normalized','Position',[0.365,0.29,0.1,0.05]);
    T2.Callback = {@AlgoParamCallback,T2Text,'t2',1};

    % scaleF slider and text
    ScaleF = uicontrol(f,'Style','slider','Min',0,'Max',15,'ForegroundColor','b',...
                      'SliderStep',[1/15 1/15],...
                      'Units','normalized','Position',[0.5,0.25,0.125,0.04],'Value',scaleF-4);
    ScaleFText = uicontrol(f,'Style','text','FontSize',18,...
                           'String',['scaleF: ',num2str(scaleF)],...
                           'Units','normalized','Position',[0.515,0.29,0.1,0.05]);   
    ScaleF.Callback = {@AlgoParamCallback,ScaleFText,'scaleF',4};
                       
    % Recompute button
    refreshImg = imread('refresh.jpg');
    Recompute = uicontrol(f,'Style','pushbutton','String','RECOMPUTE','FontSize',18,...
                          'Units','normalized','Position',[0.1,0.1,0.12,0.07]);  
    Recompute.Callback = {@computeActiveEMG,TimeWin,T1,T2,ScaleF,man_switch,...
                          Page,PageNoText,pagesteps,status_text,refreshImg};
    
    % Close figure button
    Closefig = uicontrol(f,'Style','pushbutton','String','DONE','FontSize',18,...
                         'Units','normalized','Position',[0.02,0.1,0.07,0.07]);
    Closefig.Callback = {@closeFig,minsize};
  
end
   