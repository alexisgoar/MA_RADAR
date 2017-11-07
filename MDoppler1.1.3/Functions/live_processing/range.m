function s = range(dd,txi,rxi,nfft)
signal  = dd(:,txi,rxi);
s = fft(signal,nfft,1)./size(signal,1);
s = s(1:end/2+1,:,:);
end