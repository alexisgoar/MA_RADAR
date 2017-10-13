addpath ../../Classes/
addpath(genpath( '../../Functions/')); 
% First define targets, rx, tx and signal if not the discreteSystem will
data = matfile('../../Data/walker_2.mat');
process = realTimeProcessing(data);
start_rt(process);





