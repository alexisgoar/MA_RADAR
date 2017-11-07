clc;
clear all;
close all;



delete(instrfind);

%port = 'COM24';
%s = SensorSerialInterface(port);
sensorIP = '192.168.23.38';

% parameter

rxChannelOrder = [3 4 1 2]; % [ADC2_E, ADC2_F, ADC2_C, ADC_D]

numRxCh           = length(rxChannelOrder);
numTxCh           = 24;


%num_ramp_up       = 242;
%num_ramp_parking  = 48;

num_ramp_up       = 1280;   % 384 us
num_ramp_parking  = 12;

num_ramp_wait     = 18;     % 6 us
num_ramp_down     = 64;     % 19,2 us

num_ramp_speed    = 2*num_ramp_parking;
%num_ramp_speed    = 0;

num_cyc_parking   = (num_ramp_parking*2)-1;
num_cyc_speed     =  num_ramp_speed+1;

numSamplesBuf = (num_ramp_up + num_ramp_wait + num_ramp_down + num_ramp_wait) * numRxCh * numTxCh;

s = SensorTcpInterface(sensorIP, 8888, numSamplesBuf);


xlim_min = 0;
xlim_max = num_ramp_up;
ylim_min = -1.5;
ylim_max = 1.5; 
window   = hanning(num_ramp_up);

ylim_min_FD = -120;
ylim_max_FD = -50;

f = 20e6/6;

num_samples = (num_cyc_parking + num_cyc_speed)*(num_ramp_up + num_ramp_wait + num_ramp_down + num_ramp_wait);

% values parking
values_parking = zeros(numRxCh,num_ramp_up);
for index1=1:numRxCh
    start = (index1-1)*2*(num_ramp_up+num_ramp_wait+num_ramp_down+num_ramp_wait)+1;
    stop = start + num_ramp_up - 1;
    values_parking(index1,:) = start:stop; 
end

% values speed
values_speed = zeros(num_ramp_speed,num_ramp_up);

for index1=1:num_ramp_speed
    start = (num_cyc_parking+index1)*(num_ramp_up+num_ramp_wait+num_ramp_down+num_ramp_wait)+1;
    stop  = start+num_ramp_up - 1;
    values_speed(index1,:) = start:stop;
end
values_speed = reshape(values_speed',[],1);

T_parking = (0 : num_ramp_up-1).'/f*1e6; % in us
T_speed   = (0 :  (num_ramp_up*(num_cyc_speed-1)-1)).'/f*1e6;

% fft parameter
sWindow = hanning(num_ramp_up);
nfft    = 2^nextpow2(length(sWindow)) * 2;


% set up plot environment
fig    = zeros(1,numTxCh);
ax     = zeros(numTxCh, numRxCh);
hplots = zeros(numTxCh, numRxCh);


% buttons
fig(index1) = figure('WindowStyle','docked','Name','Buttons','NumberTitle','off');
btn=uicontrol('style','togglebutton','position',[100, 100, 100, 40],'string','stop');
set(btn,'value',1);
btnf=uicontrol('style','togglebutton','position',[300, 100, 100, 40],'string','f/t');


for index1 = 1 : numTxCh
    fig(index1) = figure('WindowStyle','docked','Name',['TX',num2str(index1)],'NumberTitle','off');
    for i = 1 : numRxCh
        ax(index1,i)     = subplot(3, 4, i);
        hplots(index1,i) = plot(nan(1024, 1));
        grid on;
        title(i);
    end
end


while get(btn,'value')
    
    %data = s.fetchSingleSnapshot();
    data = s.fetchSingleSnapshot();
%     
%     py_data = s.get_measurement();
%     data = double(typecast(uint8(py_data.tobytes()), 'int16')) / 2^11;
% data = reshape(data, 6, [], 2);
% data = permute(data, [3, 1, 2]);
% data = reshape(data, 12, []);
    data = reshape(data, numRxCh, []);
    data = permute(data, [2, 1]);
    data = data(:, rxChannelOrder);
    data = double(data) / 2^11;
% 
%     temp = data;
% 
%     data(:,1) = temp(:,8);
%     data(:,2) = temp(:,7);
%     data(:,3) = temp(:,10);
%     data(:,4) = temp(:,9);
%     data(:,5) = temp(:,12);
%     data(:,6) = temp(:,11);
%     data(:,7) = temp(:,2);
%     data(:,8) = temp(:,1);
%     data(:,9) = temp(:,4);
%     data(:,10) = temp(:,3);
%     data(:,11) = temp(:,6);
%     data(:,12) = temp(:,5);

    data = reshape(data, [], numTxCh, numRxCh);

    % plot parking --------------------------------------------------------
    for index1 = 1 : numTxCh
        for i = 1 : numRxCh
            if ~get(btnf,'value') % plot time
                set(hplots(index1,i), 'YData', data(1:num_ramp_up, index1, i));
                %set(hplots(index1,i), 'XData', T_parking);
                set(hplots(index1,i), 'XData', 1:1:num_ramp_up);
                ylim(ax(index1,i),[ylim_min ylim_max]);
                xlim(ax(index1,i), [1 num_ramp_up]);
                %xlim(ax(index1,i), [T_parking(1) T_parking(end)])
            else
                [pxx, ffd] = pwelch(data(1:num_ramp_up, index1, i), sWindow, 0, nfft, f);
                ppxx = pow2db(pxx);

                set(hplots(index1,i), 'YData', ppxx);
                set(hplots(index1,i), 'XData', ffd/1e3);
                ylim(ax(index1,i), [ylim_min_FD ylim_max_FD])
                xlim(ax(index1,i), [0 ffd(end)/1e3])
            end
        end
    end
    % end plot parking ----------------------------------------------------

    % plot speed  
%     index1 = 13; 
% 
%     for i = 1 : numRxCh
%         if ~get(btnf,'value') % plot time
%             set(hplots(index1,i), 'YData', data(values_speed, i) );
%             set(hplots(index1,i), 'XData', T_speed);
%             ylim(ax(index1,i), [ylim_min ylim_max])
%             xlim(ax(index1,i), [T_speed(1) T_speed(end)])
%         else
%             [pxx, ffd] = pwelch( data(values_speed, i), sWindow, 0, nfft, f );
%             ppxx = pow2db(pxx);
% 
%             set(hplots(index1,i), 'YData', ppxx);
%             set(hplots(index1,i), 'XData', ffd/1e3);
%             ylim(ax(index1,i), [ylim_min_FD ylim_max_FD])
%             xlim(ax(index1,i), [0 ffd(end)/1e3])
%         end
%     end
    drawnow
    
end % while



s.close();
