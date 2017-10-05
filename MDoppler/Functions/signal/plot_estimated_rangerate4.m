%Plots the received signal in time domain for a single path 
function s = plot_estimated_rangerate4(obj)
NPulses = 50; 
NObj = size(obj.target,2); 
NSamples = 54; 
sampleRate = NSamples/obj.tx.tchirp; 
sampleFreq = 1/sampleRate; 

Nout = 2;

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
    signal_rr(chirp) = signal(Nout);
    
end

freq_rr = -(NPulses-1)/(2*NPulses*obj.tx.tchirp):1/(obj.tx.tchirp*NPulses):(NPulses-1)/(2*NPulses*obj.tx.tchirp); 
freq_rr = freq_rr;  

%freq_rr = 0:1/(obj.tx.tchirp*NPulses):(NPulses-1)/(NPulses*obj.tx.tchirp);
v = freq_rr*obj.tx.lambda/4; 
v = v(1:2:end);
size(v);
freq_rr = freq_rr(1:2:end);
figure; 
hold on; 

for chirp = 1:NSamples
    signal_to_transform = signal_freq(1:2:end,chirp); 

    if chirp == 2
        plot(v,abs(fft((signal_rr(1:2:end))))); 
    end
    if chirp == 11
        %plot(v,abs((signal_to_transform))); 
    end
    if chirp == 30
       % plot(v,abs(fftshift(fft(signal_to_transform)))); 
    end
    
    n = size(signal_to_transform,1); 
    signal_transformed = zeros(size(signal_to_transform)); 
    for i = 1:n
        for j = 1:n
            signal_transformed(i) = signal_transformed(i) + ...
                signal_to_transform(j)*exp(1i*2*pi*freq_rr(j)*(i-1)*obj.tx.tchirp); 
        end
    end
    
   % signal_freq_all(:,chirp) = fftshift(signal_transformed); 
  signal_freq_all(:,chirp) = fftshift(fft((signal_to_transform))); 
    
end
signal_freq_rr = fft(signal_rr(1:2:end));

freq =0:1/(obj.tx.samplingRate*NSamples):(NSamples-1)/(NSamples*obj.tx.samplingRate);
R = obj.tx.c*freq/(obj.tx.k*2);


R
[R_plot,v_plot] =meshgrid(R,v); 
size(v_plot)
size(R_plot)

figure;
set(0,'DefaultFigureWindowStyle','docked');

h = surf(R_plot,v_plot,abs(signal_freq_all)); 
view(0, 90);
set(h,'edgecolor','none');






end