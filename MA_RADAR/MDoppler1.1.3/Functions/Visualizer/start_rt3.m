function start_rt3(obj)
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
%----------------------Init-----------------------------------------------%

ii = 1; 
while ii <= obj.nCycles
    cla(ax1); 
    cla(ax2); 
%% Ranging
    %s_range = obj.range(1,1,ii); 

    %plot(ax1,obj.rLin,abs(s_range)); 

    
    s_doppler = obj.dopplerRange(1,ii);
    [v,R]= meshgrid(obj.vLin,obj.rLin); 
    h = pcolor(ax2, v,R,abs(s_doppler)); 
    set(h,'edgecolor','none');
    
    s_azimuth = obj.rangeAzimuth(1,ii); 
    [theta,R] = meshgrid(obj.thetaLin,obj.rLin); 
    h = surf(ax1,R.*sin(theta),R.*cos(theta),abs(s_azimuth)); 
    set(h,'edgecolor','none');
    
    drawnow;
    
    ii = ii+1; 
end


    function terminate(source,event)
        
        t =10001;
        close(f)
        close all
        clear all
        error('hi'); 
    end


end