%Plots the received signal in time domain for a single path 
function s = plot_estimated_rangerate3(obj)
i = 1;
txn = obj.tx.numberofElements; 
rxn = obj.rx.numberofElements; 
range_rate = [0:0.2:5];

txi = 1; 
rxi = 1; 
NPulses = 100; 
% Get the time domain signal for all targets
while obj.tx.chirpi < NPulses
    for j = 1:size(obj.target,2)
        s(i,j) =(rxSignal3(obj,obj.tx.time,txi,rxi,j));
    end
    timeStamp(i) = obj.tx.time;
    obj.tx.nextStep_sampling();
    i = i+1;
end
obj.tx.resetTime();
s_time = sum(s,2);

N=size(timeStamp,2);
freq =0:1/(obj.tx.samplingRate*N):(N-1)/(N*obj.tx.samplingRate);
R = obj.tx.c*freq/(obj.tx.k*2);

% FFT to get spectrum

%s_freq = fft(s_time);
% K = [0:1:N-1]; 
% for ii = 1:N
%     s_out = 0; 
%     for iii = 1:N
%         s = exp(-1i*2*pi*K(ii)*(iii-1)/N); 
%         s_out = s_out + s_time(iii)*s; 
%     end
%     s_freq(ii) = s_out; 
%     
%     
% end
s_time = s_time(1:54:end); 
timeStamp = timeStamp(1:54:end); 
% FFT for range_rate 
N=size(timeStamp,2);
sR = obj.tx.samplingRate*54; 
freq =0:1/(sR*N):(N-1)/(N*sR);
K = [0:1:N-1]; 
for ii = 1:N
    s_out = 0; 
    for iii = 1:N
        s = exp(-1i*2*pi*K(ii)*(iii-1)/N); 
        s_out = s_out + s_time(iii)*s; 
    end
    s_freq2(ii) = s_out; 
    
    
end



for range_ratei = 1:size(range_rate,2)
    arg = 4*pi*obj.tx.frequency;
    N2 = max(size(s_time)); 
    
            s_out = 0; size(s_time,2);
            for int = 1:N2
               s = exp(-1i*arg*(int-1)/N2);
               s_out = s_out + s_time(int)*s; 
            end

                     
            s_freq_rrate(range_ratei) = s_out;
            
            
end
%size(s_freq_rrate);

%profile = mtimes(s_freq,s_freq_rrate);


[Rrate_plot,R_plot] = meshgrid(range_rate,R);
figure;
set(0,'DefaultFigureWindowStyle','docked');
%hold on;

%h = surf(R_plot,Rrate_plot,abs(profile)); 
%set(h,'edgecolor','none');

%figure;
%plot(range_rate,abs(s_freq_rrate)) ;

%figure; 
plot(freq,abs(s_freq2)); 



end