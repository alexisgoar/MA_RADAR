function s = dopplerRange(dd,rxi,nfft)
%signal selection
s = dd(:,:,rxi);
%fast time fft
s = fft(s, nfft,1)./size(s,1);
%slow time fft
s = fftshift(fft(s,32,2),2)./size(s,2);
s = s(1:end/2+1,:,:);
end