function s_out = MUSIC(dd,txi,nfft,steeringVector)
s = dd(:,txi,:);
s = squeeze(s);
ntheta = size(steeringVector,2); 
s = fft(s,nfft,1)./size(s,1);
s = transpose(s(57,:,:));
s = corrcoef(s*s');
[V,D] = eig(s);
[D I] = sort(diag(D),'descend');
V = V(:,I);
U_n = V(:,2:end);
for thetai = 1:ntheta
    sV = steeringVector(:,thetai);
    a = sV'*U_n*U_n'*sV;
    s_out(:,thetai) = sV'*sV/a;
    s_out(:,thetai) = sV'*s*sV/(sV'*sV); 
end

end