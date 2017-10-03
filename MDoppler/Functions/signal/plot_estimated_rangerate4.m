%Plots the received signal in time domain for a single path 
function s = plot_estimated_rangerate4(obj)
NPulses = 100; 
NObj = size(obj.target,2); 
NSamples = 54; 
sampleRate = NSamples/obj.tx.tchirp;
sampleFreq = 1/sampleRate; 

signal_freq = zeros(NPulses,NSamples); 
for chirp = 1:NPulses
    signal = zeros(NSamples,1); 
    timeStamp  = zeros(NSamples,1); 
    for k = 1:NSamples
        for j=1:NObj
          signal(k)=signal(k)+rxSignal3(obj,obj.tx.time,1,1,j); 
        end
       timeStamp(k) = obj.tx.time; 
       obj.tx.nextStep_sampling(); 
    end
    signal_rr(chirp) = signal(NSamples); 
    signal_freq(chirp,:) = fft(signal);
end

freq =0:1/(obj.tx.samplingRate*NSamples):(NSamples-1)/(NSamples*obj.tx.samplingRate);
R = obj.tx.c*freq/(obj.tx.k*2);

figure;
set(0,'DefaultFigureWindowStyle','docked');
hold on; 

for i = 1:50
plot(R,abs(signal_freq((2*i-1),:))); 
end



end