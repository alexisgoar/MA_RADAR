addpath ../Classes/
addpath(genpath( '../Functions/')); 

% Data import
if exist('data','var') == 0
    data = matfile('../Data/ODR451/08-Nov-2017-reflector.mat');
end
%Link data to signal processing class
if exist('process','var')==0
    process = realTimeProcessing_ODR451(data);
end
% Display
start_rt3(process); 



