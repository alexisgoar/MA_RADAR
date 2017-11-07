addpath ../Classes/
addpath(genpath( '../Functions/')); 

% Data import 

if exist('data','var') == 0
    data = matfile('../Data/test4.mat');
end
%Link data to signal processing class
if exist('process','var')==0
    process = realTimeProcessing(data);
end


% Display
start_rt2(process); 



