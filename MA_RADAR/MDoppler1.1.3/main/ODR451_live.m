addpath ../Classes/
addpath(genpath( '../Functions/')); 
addpath ../Skripts/
%% Figure Setup
set(0,'DefaultFigureWindowStyle','docked');
f = figure('Visible','off');
%Close btn
btn = uicontrol('Style','pushbutton','String','Stop',...
    'Position',[20 780 100 40],...
    'Callback',@terminate);
%timer
str = ['Time =',num2str(0),'s'];
txt = uicontrol('Style','text',...
    'Position',[10 600 120 40],...
    'String',str);
% performance indicator
str2 = ['Range-Azimuth Processing Time\n',num2str(0), ' s'];
txt2 = uicontrol('Style','text',...
    'Position',[10 580 120 40],...
    'String',str2);
str3 = ['Range-Doppler Processing Time\n',num2str(0), ' s'];
txt3 = uicontrol('Style','text',...
    'Position',[10 520 120 40],...
    'String',str3);
str4 = ['Tracking:   ',num2str(0), ' s'];
txt4 = uicontrol('Style','text',...
    'Position',[10 460 120 40],...
    'String',str4);
% Axes
ax1 = axes('Position',[0.15 0.5 0.7 0.45]);
xlabel(ax1,'Horizontal Range [m]');
ylabel(ax1,'Vertical Range [m]'); 
%axis(ax1,[-80 80    0  100]);
colorbar; 
caxis([0 0.2]);
hold on;
view(0, 90)
% Ax 2
ax2 = axes('Position',[0.15 0.05 0.33 0.35]);
xlabel(ax2, 'Range [m]'); 
ylabel(ax2, 'Range-Rate [m/s]');  
%caxis([0,1000]); 
colorbar; 
hold on;
%axis(ax2,[0 80  -15  15]);
view(0, 90)
% Ax 3 
ax3 = axes('Position',[0.52 0.05 0.33 0.35]);
title(ax3,' Tracking'); 
xlabel(ax3, 'Horizontal Range [m]'); 
ylabel(ax3, 'Vertical Range [m]'); 
colorbar; 
hold on;
axis(ax3,[-80 80    0  120]);
%Start visualizer
f.Visible = 'on';
%% Sensor configuration 
sensorIP = '192.168.23.38';
sensorPort = 8888;
swOrder = [1:24];
rxChannelOrder = [3 4 1 2]; 
numTxChannels = 3 * 8;
nUp = 1280;
numSamplesPerRamp = nUp + 18 + 64 + 18;
nfft = 2048;
B = 900e6;
rLin = linspace(0,96e9/B,nfft/2+1);
numRxChannels = length(rxChannelOrder);
numSamplesBuf = numRxChannels * numTxChannels * numSamplesPerRamp;
s = SensorTcpInterface(sensorIP, sensorPort, numSamplesBuf);
%% Functions init
ii=1;
ntheta = 120; 
thetaLin = linspace(-90,90,ntheta)*pi/180;
steeringVector = zeros(numRxChannels,ntheta);
for i = 1:numRxChannels
    for j = 1:ntheta
        steeringVector(i,j) = exp(1i*pi*(1-i)*sin(thetaLin(j)));
    end
end


while get(btn,'value')
    % Get Data
    d = s.fetchSingleSnapshot();
    dd = reshape(d, numRxChannels, []);
    dd = permute(dd, [2 1]);
    dd = dd(:, rxChannelOrder);
    dd = reshape(dd, numSamplesPerRamp, [], numRxChannels);
    dd = dd(1:nUp,:,:);
    dd = dd(:,swOrder,:);
    dd = double(dd) / 2^11;
    % Process the data 
    rSpec = fft(dd,nfft,1)./size(dd,1);
    rSpec = rSpec(1:end/2+1,:,:);

    
    
    
    
    
    
    drawnow;
    disp(ii)
    ii = ii+1;
end
%%
s.close();
