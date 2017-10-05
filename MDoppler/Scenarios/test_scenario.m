addpath ../Classes/
addpath(genpath( '../Functions/')); 
% First define targets, rx, tx and signal if not the discreteSystem will
% not be linked

%Definition of Setup
test = target(0,2.9970,0,0,0,0); 
test2 = target(0,4.4969,0,0,-10,0); 
test3 = target(0,35.9751,0,0,0,0); 
test4 = target(0,70.4512,0,0,0,0); 
test5 = target(0,2,0,0,0,0); 
test6 = target(0,17,0,0,0,0); 
test7 = target(0,7,0,0,0,0); 
test8 = target(0,8,0); 
test9 = target(0,9,0);
test10 = target(0,10,0); 
rx = rxarray(4,0,0,0);
         % Plots frequency of the signal vs time for transmitter txi 
tx = txarray(2,0.1053,0,0); 


signal = signal2(tx,rx,test,test2,test3,test4); 

plot_estimated_rangerate4(signal); 


 