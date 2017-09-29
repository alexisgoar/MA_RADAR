addpath ../Classes/

test = target; 
test.x = 0; 
test.y = 120; 
test.z = 0; 
test.vx = 5; 

test2  = target(0,100,0); 
test3 = target(0.1,30,0); 
test4 = target(0,0,0); 



rx = rxarray(4,0,0,0);
 
tx = txarray(2,0.1053,0,0); 

testsignal = signal(tx,rx,test); 
testsignal.receivedSignal(1,2,1);
testsignal.deltaT;
%testsignal.plot_estimated_ranges();

multiplesignal = signal2(tx,rx,test,test2,test3,test4); 
a  =multiplesignal.target(1).x;
multiplesignal.plot_setup(); 
 
%test.animate(0.001,0,0.05,rx,tx); 



