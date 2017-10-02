%Plots the received signal in time domain for a single path 
function s = plot_estimated_range2(obj,txi,rxi,NPulses)
i = 1;

while obj.tx.chirpi < NPulses
    for j = 1:size(obj.target,2)
        s(i,j) =(rxSignal2(obj,obj.tx.time,txi,rxi,j));
    end 
    timeStamp(i) = obj.tx.time;
    obj.tx.nextStep_sampling();
    i = i+1;
end

N=size(timeStamp,2);
freq =0:1/(obj.tx.samplingRate*N):(N-1)/(N*obj.tx.samplingRate);
R = obj.tx.c*freq/(obj.tx.k*2);

s_time = sum(s,2); 
s_freq = fft(s_time); 

h = plot(R,abs(s_freq));


end