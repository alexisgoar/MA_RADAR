addpath ../../Classes/
addpath(genpath( '../../Functions/')); 
addpath ../../Skripts/
x = clock; 

file_name = ['../../Data/ODR451/',date,'-',num2str(x(4)),num2str(x(5)),'.mat']; 
% Sensor configuration 
sensorIP = '192.168.23.35';
sensorPort = 8888;

swOrder = [1:24];
rxChannelOrder = [3 4 1 2]; % [ADC2_E, ADC2_F, ADC2_C, ADC_D]
numTxChannels = 3 * 8;
nUp = 1280;
numSamplesPerRamp = nUp + 18 + 64 + 18;

nfft = 2048;
B = 900e6;
rLin = linspace(0,96e9/B,nfft/2+1);
%%

numRxChannels = length(rxChannelOrder);
numSamplesBuf = numRxChannels * numTxChannels * numSamplesPerRamp;
s = SensorTcpInterface(sensorIP, sensorPort, numSamplesBuf);


ii=1;
% Desired number of cycles
numCycles = 200; 
num_ramp_up       = 1280; 
raw_data = zeros(num_ramp_up, numTxChannels, numRxChannels, numCycles); 
while ii <= numCycles
    tic
    d = s.fetchSingleSnapshot();
    dd = reshape(d, numRxChannels, []);
    dd = permute(dd, [2 1]);
    dd = dd(:, rxChannelOrder);
    dd = reshape(dd, numSamplesPerRamp, [], numRxChannels);
    dd = dd(1:nUp,:,:);
    dd = dd(:,swOrder,:);
    dd = double(dd) / 2^11;


 
    raw_data(:,:,:,ii) = dd; 
    ii = ii+1;
    toc
end


save(file_name,'raw_data','B','-v6'); 
%%
s.close();
