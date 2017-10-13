addpath ../Classes/
addpath(genpath( '../Functions/')); 
% First define targets, rx, tx and signal if not the discreteSystem will
% not be linked

%Definition of Setup
test1 = target(0,29.5,0,0,200000,0); 
test2 = target(40,40,0); 
test3 = target(-30,50,0,1000000,0,0); 
test4 = target(0,70,0,-1000000,-1000000,0); 

         % Plots frequency of the signal v time for transmitter txi 
tx = txarray(2,0.1053,0,0); 
rx = rxarray(4,0,0,0); 

signal = signal3(tx,rx,test1,test2,test3,test4); 
process = signalProcessing(signal); 
 


s = process.rangeAzimuth(); 

start(process); 

