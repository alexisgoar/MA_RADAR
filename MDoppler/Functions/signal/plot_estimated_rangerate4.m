%Plots the received signal in time domain for a single path 
function s = plot_estimated_rangerate4(obj)
NPulses = 100; 
NObj = size(obj.target,2); 
NSamples = 54; 
sampleRate = NSamples/obj.tx.tchirp;
sampleFreq = 1/sampleRate; 

Nout = 14;

signal_freq = zeros(NPulses,NSamples); 
signal_rr =  zeros(NPulses,1); 
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
    out = fft(signal); 
    signal_freq(chirp,:) = out;
    signal_rr(chirp) = out(Nout);
    
end

freq_rr = -(NPulses-1)/(2*NPulses*obj.tx.tchirp):1/(obj.tx.tchirp*NPulses):(NPulses-1)/(2*NPulses*obj.tx.tchirp); 
v = freq_rr*obj.tx.lambda/2; 
v = v(1:2:end);
size(v);


for chirp = 1:NSamples
   signal_freq_all(:,chirp) = fftshift(fft(signal_freq(1:2:end,chirp))); 
    
end
signal_freq_rr = fft(signal_rr(1:2:end));

freq =0:1/(obj.tx.samplingRate*NSamples):(NSamples-1)/(NSamples*obj.tx.samplingRate);
R = obj.tx.c*freq/(obj.tx.k*2);




[R_plot,v_plot] =meshgrid(R,v); 
size(v_plot)
size(R_plot)

figure;
set(0,'DefaultFigureWindowStyle','docked');

h = surf(R_plot,v_plot,abs(signal_freq_all)); 
view(0, 90);
set(h,'edgecolor','none');






end