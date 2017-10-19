addpath ../Classes/
addpath(genpath( '../Functions/')); 
% First define targets, rx, tx and signal if not the discreteSystem will
% not be linked

%Definition of Setup
test1 = target(-20,15,0,3,0,0); 
test2 = target(0,40,0,0,5,0); 
test3 = target(-30,50,0,0,-5,0); 
test4 = target(0,70,0,0,0,0); 
test5 = target(0,10,0,0,0,0); 
test6 = target(-30,0,0,0,0,0); 

         % Plots frequency of the signal v time for transmitter txi 
tx = txarray(2,0.1053,0,0); 
rx = rxarray(4,0,0,0); 

signaltest = signal(tx,rx,test1,test2); 
process_2 = signalProcessing(signaltest); 


start(process_2); 

