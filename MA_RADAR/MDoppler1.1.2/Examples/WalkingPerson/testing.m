addpath ../../Classes/
addpath(genpath( '../../Functions/')); 
% First define targets, rx, tx and signal if not the discreteSystem will
% not be linked

%Definition of Setup
walking_speed = 3; 

body = target(-2,10,0,walking_speed,0,0); 
hand = target(-2,10.5,0,walking_speed,0,0);
hand.accel = 1; 


         % Plots frequency of the signal v time for transmitter txi 
tx = txarray(2,0.1053,0,0); 
rx = rxarray(4,0,0,0); 

s = signal(tx,rx,body,hand); 


process_2 = signalProcessing(s); 


start(process_2); 

