addpath ../Classes/
% Example: animate a moving target
% Tx and Rx Definitions
rx = rxarray(4,0,0,0);
tx = txarray(2,0.1053,0,0); 
%Definition of the moving target 
target3 = target(-2, 50,0,1,0,0); 

figure; 
axis([-2,2,0,70]); 
set(0,'DefaultFigureWindowStyle','normal');
target3.animate(0.01,0,2,rx,tx); 
