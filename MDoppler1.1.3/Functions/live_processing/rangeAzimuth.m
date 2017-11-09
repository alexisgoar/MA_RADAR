function s_out = rangeAzimuth(dd,txi,steeringVector,nfft,ntheta)
ntheta = size(steeringVector,2); 
%signal selection
s = dd(:,txi,:);
s = squeeze(s);
% range estimation
s = fft(s,nfft,1)./size(s,1);
s = s(1:end/2+1,:,:);

%s_out init
s_out = zeros(nfft/2+1,ntheta);
%Azimuth profile
for thetai = 1:ntheta
    sV = steeringVector(:,thetai);
    sV = (sV)' ;
    sV = repmat(sV,1,1,nfft/2+1);
    sV = permute(sV,[3 2 1]);
    s_out(:,thetai) =sum(sV.*s,2);
end
end