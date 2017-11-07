function generate_signal(obj,Ncycles,name)
txN = obj.tx.numberofElements; 
rxN = obj.rx.numberofElements; 
NPulses = obj.NPulses; 
NSamples = obj.tx.samplesPerChirp*txN; 
signal = zeros(txN,rxN,NPulses*NSamples,Ncycles); 
time = zeros(NPulses*NSamples*Ncycles,1); 
trueRange = zeros(NPulses*NSamples*Ncycles,4,obj.numberofTargets); 
for i = 1:Ncycles
    index = ((i-1)*NPulses*NSamples+1):1:(i*NPulses*NSamples); 
   [signal(:,:,:,i),time(index),d] = obj.dataCube(1); 
   time(index) = time(index) + (i-1)*obj.tx.tchirp*NPulses*obj.tx.numberofElements;
   trueRange(index,:,:) = d; 
end
%-------Export of signal information---------------------------------------

Ns = obj.tx.samplesPerChirp; 
sR = obj.tx.samplingRate; 
k = obj.tx.k; 
tc = obj.tx.tchirp; 
lambda = obj.tx.lambda; 
%--------------------------------------------------------------------------
%----Steering Matrix for Azimuth calculation-------------------------------
theta = (-90:1:90)*pi/180;
s = zeros(txN,rxN,size(theta,2)); 
for i = 1:size(theta,2) 
    s(:,:,i) = obj.steeringVectorMatrix(theta(i)); 
end
steeringVectorMatrix = s; 
%--------------------------------------------------------------------------
save(name,'signal','time','trueRange','Ns','sR',...
    'k','tc','lambda','NPulses',...
    'theta','steeringVectorMatrix','-v6'); 
end