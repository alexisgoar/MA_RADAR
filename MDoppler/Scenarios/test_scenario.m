addpath ../Classes/
addpath(genpath( '../Functions/')); 
% First define targets, rx, tx and signal if not the discreteSystem will
% not be linked

%Definition of Setup
test = target; 
test.x = 0; 
test.y = 120; 
test.z = 0; 
test.vx = 5; 
test2  = target(0,100,0); 
test3 = target(0.1,60,0); 
test4 = target(0,20,0); 
rx = rxarray(4,0,0,0);
         % Plots frequency of the signal vs time for transmitter txi 
tx = txarray(2,0.1053,0,0); 


multiplesignal = signal2(tx,rx,test,test2,test3,test4); 
figure; 
hold on; 
plot_rxSignal(multiplesignal,1,1,10); 
tx.resetTime(); 
figure; 
hold on; 
plot_estimated_ranges2(multiplesignal,5); 




