addpath ../../Classes/
addpath(genpath( '../../Functions/')); 
addpath ../../Skripts/
x = clock; 

file_name = ['../../Data/ODR451/',date,'-',num2str(x(4)),num2str(x(5)),'.mat']; 
% Sensor configuration 
sensorIP = '192.168.23.38';
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

%%
close all;
figure;
set(gcf,'position',get(gcf,'position').*[.5 1 2 1]);
btn = uicontrol('style','togglebutton','value',1,'position',[0 0 20 20],'string','X');

tic
ii=1;
% Desired number of cycles
numCycles = 100; 
raw_data = zeros(num_ramp_up, numTxChannels, numRxChannels, numCycles); 
while ii <= numCycles
    d = s.fetchSingleSnapshot();
    dd = reshape(d, numRxChannels, []);
    dd = permute(dd, [2 1]);
    dd = dd(:, rxChannelOrder);
    dd = reshape(dd, numSamplesPerRamp, [], numRxChannels);
    dd = dd(1:nUp,:,:);
    dd = dd(:,swOrder,:);

    dd = double(dd) / 2^11;
    rSpec = fft(dd,nfft,1)./size(dd,1);
    rSpec = rSpec(1:end/2+1,:,:);
    
    subplot(211);
    plot(dd(:,:));
    grid on;
    ylim([-1, 1]);
    xlabel('sample');
    ylabel('U / V');
    
    subplot(212);
    plot(rLin,20*log10(abs(rSpec(:,:))));
    grid on;
    ylim([-80 0]);
    xlim([rLin(1) rLin(end)]);
    xlabel('range / m');
    ylabel('dB');
    
    drawnow;

    disp(ii)
    
    raw_data(:,:,:,ii) = dd; 
    ii = ii+1;
end
toc
save(file_name,'raw_data','B','-v6'); 
%%
s.close();
