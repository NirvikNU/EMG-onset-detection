# EMG-onset-detection
A semi-automatic MATLAB GUI based App to find onset and offset times of EMG activity 
This MATLAB package computes the onset and offset times of EMG signals based on the following publication:
Dapeng Yang, Huajie Zhang, Yikun Gu, Hong Liu, Accurate EMG onset detection in pathological, weak and noisy myoelectric signals. Biomedical Signal Processing and Control, Volume 33, 2017, Pages 306-315, https://doi.org/10.1016/j.bspc.2016.12.014. (http://www.sciencedirect.com/science/article/pii/S1746809416302269)
The GUI interface also allows for manual correction and tuning of parameters of the automated algorithm
INPUTS: See active_EMG_auto.m for details of inputs
EXAMPLE: fake_EMG = rand(1000,100);
active_EMG = active_EMG_detector(fake_EMG,100,100,500,8,1000);
OUPUT: emg_active = [Time samples vs. epochs] of active EMG periods
MATLAB stackexchange link: [![View EMG-onset-detection on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/84575-emg-onset-detection)
