addpath ../Classes/
addpath(genpath( '../Functions/')); 
% Example: The definition of targets, rxarray and txarray
% All of the previous are to be linked in a signal class 

% Tx and Rx Definitions
rx = rxarray(4,0,0,0);
tx = txarray(2,0.1053,0,0); 

% Definition of three static targets
target1 = target(0,100,0); 
target2 = target(1,30,0); 
target3 = target(-1, 50,0); 

% Definition of a signal class that links all objects 
signal = signal(tx,rx,target1,target2,target3); 
hold on; 
%plot everything
plot_setup(signal); 







