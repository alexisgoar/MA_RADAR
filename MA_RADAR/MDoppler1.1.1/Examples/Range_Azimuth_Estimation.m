addpath ../Classes/
addpath(genpath( '../Functions/')); 

profile on 

target1 = target(0,29.5,0); 
target2 = target(40,40,0); 
target3 = target(-30,50,0); 
target4 = target(0,70,0); 

rx = rxarray(4,0,0,0);
tx = txarray(2,0.1053,0,0); 

signal = signal2(tx,rx,target1,target2,target3,target4); 

figure; 
plot_setup(signal); 
hold on; 


plot_azimuth_profile(signal,3);

profile viewer
profile clear