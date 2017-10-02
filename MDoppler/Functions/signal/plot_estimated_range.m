% plots the estimated range based on the received signal after
% applying an FFT for transimeter txi and receiver rxi
% for a single target
function h = plot_estimated_range(obj,txi,rxi,targeti)
numberofChirps = 1;
samplesperChirp = obj.tx.tchirp/obj.tx.samplingRate;
time = 0:obj.tx.tchirp/samplesperChirp:obj.tx.tchirp*numberofChirps;
for i = 1:size(time,2)
    s = receivedSignal(obj,time,txi,rxi,targeti);
end
N=size(time,2);
freq =0:1/(obj.tx.samplingRate*N):(N-1)/(N*obj.tx.samplingRate);
R = obj.tx.c*freq/(obj.tx.k);
sfd = fft(s);
h = plot(R,abs(sfd));
end