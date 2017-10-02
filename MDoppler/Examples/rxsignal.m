addpath ../Classes/
addpath(genpath( '../Functions/')); 
% Example: Frequency of the signal received from four different targets
%Note that the positions of the targets have been exaggerated in order 
% to show the delay caused by the distance 
%Definition of Setup
target1 = target(0,1000,0); 
target2 = target(0,10000,0); 
target3= target(0,15000,0); 
target4= target(0,20000,0); 
rx = rxarray(4,0,0,0); 
tx = txarray(2,0.1053,0,0); 

% For faster plotting
tx.gTimeStep = 1e-5; 

signal = signal2(tx,rx,target1,target2,target3,target4); 

plot_rxSignals(signal,10); 





