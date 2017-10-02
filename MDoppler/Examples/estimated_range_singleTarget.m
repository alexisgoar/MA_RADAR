addpath ../Classes/
addpath(genpath( '../Functions/')); 
% Example: Estimated Range Single target
% Tx and Rx Definitions
rx = rxarray(4,0,0,0);
tx = txarray(2,0.1053,0,0); 

% Definition of three static targets
target1 = target(0,100,0); 


% Definition of a signal class that links all objects 
signal = signal2(tx,rx,target1);
%plot estimated range
plot_estimated_ranges(signal,1); 