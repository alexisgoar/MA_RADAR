addpath ../Classes/

test = target; 
test.x = 0; 
test.y = 120; 
test.z = 0; 




rx = rxarray(4,0,0,0);
 
tx = txarray(2,0.1053,0,0); 

testsignal = signal(tx,rx,test); 
testsignal.receivedSignal(1,2,1)
testsignal.deltaT
testsignal.plotreceived()
%figure;
%hold on;
%plot(test); 
%plot(rx); 
%plot(tx); 



