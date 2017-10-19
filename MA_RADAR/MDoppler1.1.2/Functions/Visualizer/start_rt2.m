function start_rt2(obj)
%------------------Figure Setup------------------------------------------%
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
str4 = ['In development: tracking:   ',num2str(0), ' s'];
txt4 = uicontrol('Style','text',...
    'Position',[10 460 120 40],...
    'String',str4);
% Axes
ax1 = axes('Position',[0.15 0.5 0.7 0.45]);
xlabel(ax1,'Horizontal Range [m]');
ylabel(ax1,'Vertical Range [m]'); 
colorbar;
caxis([0 250]);
hold on;
ax2 = axes('Position',[0.15 0.05 0.33 0.35]);
xlabel(ax2, 'Range [m]'); 
ylabel(ax2, 'Range-Rate [m/s]'); 
colorbar; 
caxis([0,1000]); 
hold on;
ax3 = axes('Position',[0.52 0.05 0.33 0.35]);
title(ax3,' Tracking'); 
xlabel(ax3, 'Horizontal Range [m]'); 
ylabel(ax3, 'Vertical Range [m]'); 
hold on;
%Start visualizer
f.Visible = 'on';
%----------------------Init-----------------------------------------------%
txN = obj.txN;
signalN = obj.Ns;
NPulses =  120;
%to be done: Get this value automatically
Ncycles = 500;
s3 = zeros(NPulses,Ncycles);
trueRange = obj.rangeData;

targetsN = size(trueRange,3);
t = 0;
i = 1;
[~,r,theta] = obj.rangeAzimuth(1);
[~,v_plot,r_plot] = obj.dopplerRange(1);
%Index for later extraction of the range-doppler plot
% This is not a nice way of doing things but works for now
index = [1:signalN];
index2 = [1:txN:NPulses*txN]'-1;
index3 = repmat(index2*signalN,1,signalN);
index4 = repmat(index,NPulses,1);
size(index3);
size(index4);
index_end = reshape((index3+index4)',1,signalN*NPulses);
%Kalmann init
P = [1,0,0,0;0,1,0,0;0,0,0,0;0,0,0,0];
% Tracks init
deltaT = obj.tc*NPulses*txN;
aT = allTracks(deltaT); 

while t <10000
    %Clear axes
    cla(ax1)
    cla(ax2)
    %cla(ax3)
    %----------------------Range Azimuth---------------------------------%
    %Processing and performance measurement
    t01 =tic;
    s_RA = obj.rangeAzimuth(i);
    t1 = toc(t01);
    %Plot result
    h = pcolor(ax1,r.*sin(theta),r.*cos(theta),abs(s_RA));
    view(0, 90)
    set(h,'edgecolor','none');
    axis(ax1,[-80 80    0  100])
    %Plot true tagets
    for j = 1:targetsN
        plot(ax1,trueRange(i*signalN*NPulses*txN,1,j),trueRange(i*signalN*NPulses*txN,2,j),...
            'o','MarkerSize',5,'MarkerFaceColor','red','MarkerEdgeColor','black');
    end
    %Detection
    s_range = obj.ranging(i);
    index = obj.detectRange(s_range);
    [out] = obj.detectAzimuth(s_RA,index);
    %Plot detected targets
    for j = 1:size(out,1)
        rq = r(1,out(j,1));
        az = theta(out(j,2),1);
        plot(ax1,rq*sin(az),rq*cos(az),...
            'o','MarkerSize',5,'MarkerFaceColor','white','MarkerEdgeColor','black');
    end
    %Update performance indicator
    str2 = ['Range-Azimuth Processing Time = ',num2str(t1), ' s'];
    txt2.set('String',str2);
    %--------------------Range Doppler-----------------------------------%
    %Processing and performance measurement
    t02 = tic;
    s2 = obj.dopplerRange(i);
    t2 = toc(t02);
    % Variable extraction for plotting
    size(s2(1,1,index_end));
    temp = reshape(s2(1,1,index_end),signalN,NPulses);
    % Plot result
    pcolor(ax2,r_plot,v_plot,abs(temp));
    axis(ax2,[0 80  -15  15])
    view(0, 90)
    % Plot true targets
    for j = 1:targetsN
        range = sqrt(trueRange(i*signalN*NPulses*txN,1,j)^2+trueRange(i*signalN*NPulses*txN,2,j)^2);
        plot(ax2,range,trueRange(i*signalN*NPulses*txN,4,j),...
            'o','MarkerSize',5,'MarkerFaceColor','red','MarkerEdgeColor','black');
    end
    %Detection
    [out2] = obj.detectDoppler(temp,index);
    % Plot detected targets
    for j = 1:size(out2,1)
        rq = r(1,out2(j,1));
        vq = v_plot(1,out2(j,2));
        plot(ax2,rq,vq,...
            'o','MarkerSize',5,'MarkerFaceColor','white','MarkerEdgeColor','black');
    end
    % Update performance estimator
    str3 = ['Range-Doppler Processing Time =',num2str(t2), ' s'];
    txt3.set('String',str3);
    
    %--------------------TRACKING (TESTING)-----------------------------------%
    deltaT = obj.tc*NPulses*txN; 
    rK = r(1,out2(1,1));
    azK = theta(out(1,2),1);
    rrK = v_plot(1,out2(1,1)); 

    zk = [rK,azK]; 
    if i == 1
    x = [rK*sin(azK)
        rK*cos(azK)
        3
        0]; 
    else
   
    [x,P] = obj.kalmanF(zk,x,P,deltaT);

    end

    %--------TRACKING (NEW)-----------------------------------------------%
    
    detections = obj.detectAzimuth2(s_RA,index); 

    aT.read(detections);
    
        
    plot(ax3,aT.tracks(1).x_est,aT.tracks(1).y_est,...
        'o','MarkerSize',5,'MarkerFaceColor','red','MarkerEdgeColor','none');
    plot(ax3,aT.tracks(2).x_est,aT.tracks(2).y_est,...
        'o','MarkerSize',5,'MarkerFaceColor','green','MarkerEdgeColor','none');
    axis(ax3,[-80 80    0  80])

   
   
    %-------------------Next time step----------------------------------------%
    pause(.0000003);
    str = ['Time =',num2str(obj.timeData(i*obj.Ns*NPulses*txN)),'s'];
    txt.set('String',str);
    t = t +obj.tc*NPulses*txN;
    i = i +1;
end


    function terminate(source,event)
        
        t =10001;
        close(f)
        close all
        clear all
        error('hi'); 
    end


end