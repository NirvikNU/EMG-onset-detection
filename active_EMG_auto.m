% This function computes the onset and offset times of EMG signals
% based on the following publication:
% Dapeng Yang, Huajie Zhang, Yikun Gu, Hong Liu,
% Accurate EMG onset detection in pathological, weak and noisy myoelectric
% signals. Biomedical Signal Processing and Control, Volume 33, 2017, 
% Pages 306-315, https://doi.org/10.1016/j.bspc.2016.12.014.
% (http://www.sciencedirect.com/science/article/pii/S1746809416302269)
% AUTHOR: NIRVIK SINHA
% INPUTS:
% x =       2D EMG matrix, where rows are samples and columns are trials
%           noiseWin = time window of baseline EMG, must be a two element integer vector
%           stating start and end of noise sample no. 
% timeWin = length of EMG period (in sample numbers) from start which is
%           within resting condition
% t1 =      sample lenght of rectangular structural element for morphological
%           close operation
% t2 =      sample lenght of rectangular structural element for morphological
%           open operation
% Optional: scaleF =  scaling factor for standard deviation for indentifying threshold
%                     using the TK operator (refer to the paper above), values must range
%                     between 4 and 20, default value is 8, reasonable choice is between 6 to 8
% OUTPUT:    
% Onset:    Onset time samples for each trial
% Offset:   Offset time samples for each trial
% EXAMPLE:  fake_EMG = rand(1000,100);
%           active_EMG = active_EMG_auto(fake_EMG,100,100,500,8,1000);
% NOTE:     The parameters t1, t2, and scaleF may be
%           different for different EMG channels for each subject and must be
%           optimized manually by visualization unless the true onset is known (see
%           the above paper for details of optimization)

function [Onset, Offset] = active_EMG_auto(x,timeWin,t1,t2,varargin)
    
    % Check timeWin
    if ~isa(timeWin,'numeric')
        error('timeWin must be an integer')
    elseif timeWin > length(x)
        error('timeWin must be <= than EMG sample length')
    end
    
    % Check t1 and t2
    if ~isa(t1,'numeric') || ~isa(t2,'numeric')
        error('t1 and t2 must be integers')
    end
    if (t1 < 0 || t1 > length(x)) || (t2 < 0 || t2 > length(x))
        error('t1 and t2 must be valid indices of x')
    end
    
    % Check optional arguments
    scaleF = varargin{1};
    if isempty(scaleF)
        scaleF = 7.0;
    else
        if ~isa(class(scaleF), 'numeric')...
            && (scaleF < 4 || scaleF > 20)
            error('Scale factor should be between 4 and 20');
        end
    end
    
    % Demean signal
    x = x - repmat(mean(x,1),size(x,1),1);
    
    % Compute the Taeger-Kaiser energy operator
    phi = x.^2 - circshift(x,1,1).*circshift(x,-1,1);
    phi(1,:) = 0; phi(end,:) = 0;   % first and last elements are not defined
    
    % Compute threshold (mean + scaleF*std)
    thr = repmat(mean(phi(1:timeWin,:),1),size(phi,1),1) +...
          repmat(scaleF .* std(phi(1:timeWin,:),[],1),size(phi,1),1);
    
    % Identify the onset points
    t0 = zeros(size(phi));
    t0(phi > thr) = 1;
    
    % Morphological close operation
    SE = strel('rectangle',[1 t1]);
    t0_MCO = imclose(t0',SE);
    
    % Morphological open operation
    SE = strel('rectangle',[1 t2]);
    t0_MCO_MOO = imopen(t0_MCO,SE);    
    
    % Find the onset and offset times for each trial
    [r,c] = find(t0_MCO_MOO == 1);
    Onset = zeros(1,size(x,2));
    Offset = zeros(1,size(x,2));
    
    for i = 1:length(r)
        cpos = c(r == i);
        if ~isempty(cpos)
            Onset(i) = cpos(1);
            if size(cpos,1) > 1
                Offset(i) = cpos(end);
            else
                Offset(i) = NaN;
            end   
        else
            Onset(i) = NaN;
            Offset(i) = NaN;
        end        
    end
end

