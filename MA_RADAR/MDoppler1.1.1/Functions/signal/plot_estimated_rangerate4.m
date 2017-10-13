%Plots the received signal in time domain for a single path 
function s = plot_estimated_rangerate4(obj)
NPulses = 100; 
NObj = size(obj.target,2); 
NSamples = 54*2; 
sampleRate = NSamples/obj.tx.tchirp; 
sampleFreq = 1/sampleRate; 

Nout = 2;

signal_freq = zeros(NPulses,NSamples); 
signal_rr =  zeros(NPulses,1); 
figure; 
hold on;  
time2 = 0; 
for chirp = 1:NPulses
    signal = zeros(NSamples,1); 
    timeStamp  = zeros(NSamples,1); 
    for k = 1:NSamples
        for j=1:NObj
          signal(k)=signal(k)+rxSignal3(obj,obj.tx.time,time2,1,1,j)...
              +rxSignal3(obj,obj.tx.time,time2,2,1,j); 
        end
       timeStamp(k) = obj.tx.time; 
       time2 = time2+ obj.tx.samplingRate; 
       
       obj.tx.nextStep_sampling(); 
    end
    obj.tx.resetTime(); 
    out = fft(signal); 
    signal_freq(chirp,:) = out;
    signal_rr(chirp) = signal(Nout);
    plot(real(signal)); 
    
end

freq_rr = -(NPulses-1)/(2*NPulses*obj.tx.tchirp):1/(obj.tx.tchirp*NPulses):(NPulses-1)/(2*NPulses*obj.tx.tchirp); 
freq_rr = freq_rr;  

%freq_rr = 0:1/(obj.tx.tchirp*NPulses):(NPulses-1)/(NPulses*obj.tx.tchirp);
v = freq_rr*obj.tx.lambda/4; 





signal_freq_all = fftshift(fft(signal_freq,[],1),1); 

freq =0:1/(obj.tx.samplingRate*NSamples):(NSamples-1)/(NSamples*obj.tx.samplingRate);
R = obj.tx.c*freq/(obj.tx.k*2);

s = signal_freq;

[R_plot,v_plot] =meshgrid(R,v); 
figure;
set(0,'DefaultFigureWindowStyle','docked');
h = surf(R_plot,v_plot,abs(signal_freq_all)); 
view(0, 90);
set(h,'edgecolor','none');





end