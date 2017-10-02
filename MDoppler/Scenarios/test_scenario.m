addpath ../Classes/
addpath(genpath( '../Functions/')); 
% First define targets, rx, tx and signal if not the discreteSystem will
% not be linked

%Definition of Setup
test = target(10,30,0); 
test2 = target(40,40,0); 
test3 = target(-30,50,0); 
test4 = target(0,70,0); 
rx = rxarray(4,0,0,0);
         % Plots frequency of the signal vs time for transmitter txi 
tx = txarray(2,0.1053,0,0); 


multiplesignal = signal2(tx,rx,test,test2,test3,test4); 

plot_estimated_ranges2(multiplesignal,10); 
tx.resetTime(); 

plot_setup(multiplesignal); 
plot_azimuth_profile(multiplesignal,5);




