addpath ../Classes/
addpath(genpath( '../Functions/')); 
% Example of the estimated range for all targets 
%Definition of Setup
target1 = target(0,20,0); 
target2 = target(0,40,0); 
target3 = target(0,60,0); 
target4 = target(0,70,0); 
 
rx = rxarray(4,0,0,0);
tx = txarray(2,0.1053,0,0); 

signal = signal2(tx,rx,target1,target2,target3,target4); 
figure;
hold on; 

plot_estimated_range2(signal,1,1,2);
tx.resetTime(); 
plot_estimated_range2(signal,1,1,5);
tx.resetTime(); 
plot_estimated_range2(signal,1,1,10);
tx.resetTime(); 
plot_estimated_range2(signal,1,1,15); 