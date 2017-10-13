function start_rt(obj)
set(0,'DefaultFigureWindowStyle','docked');
f = figure('Visible','off');
%Close btn
btn = uicontrol('Style','pushbutton','String','Stop',...
    'Position',[20 780 100 40],...
    'Callback',@terminate);
%timer
str = ['Time =',num2str(0),'s'];
txt = uicontrol('Style','text',...
    'Position',[10 700 120 40],...
    'String',str);
% performance indicator
str2 = ['Range-Azimuth Processing Time\n',num2str(0), ' s'];
txt2 = uicontrol('Style','text',...
    'Position',[10 680 120 40],...
    'String',str2);

str3 = ['Range-Doppler Processing Time\n',num2str(0), ' s'];
txt3 = uicontrol('Style','text',...
    'Position',[10 620 120 40],...
    'String',str3);

str4 = ['Doppler-Time Processing Time\n',num2str(0), ' s'];
txt4 = uicontrol('Style','text',...
    'Position',[10 560 120 40],...
    'String',str4);
f.Visible = 'on';

%txN = obj.txN;
txN = 2; 
signalN = obj.Ns*txN;
%NPulses = obj.NPulses; 
NPulses =  120; 

%to be done: Get this value automatically
Ncycles = 500; 
s3 = zeros(NPulses,Ncycles);
trueRange = obj.rangeData; 

targetsN = size(trueRange,3); 

ax1 = axes('Position',[0.15 0.5 0.7 0.45]);
hold on;

ax2 = axes('Position',[0.15 0.05 0.33 0.35]);
hold on; 

ax3 = axes('Position',[0.52 0.05 0.33 0.35]);
hold on; 
t = 0;
i = 1; 
[~,r,theta] = obj.rangeAzimuth(1);
[~,r2,v] = obj.dopplerRange(1);

while t <10000
    cla(ax1)
    cla(ax2)
    cla(ax3)
    t01 =tic;
    s = obj.rangeAzimuth(i);
    t1 = toc(t01); 
    

    current_time = obj.timeData(i*obj.Ns*NPulses*txN);
                                    
    t02 = tic; 
    s2 = obj.dopplerRange(i);
    t2 = toc(t02); 
    temp = reshape(s2(1,1,:),signalN,NPulses);
    h = pcolor(ax1,r.*sin(theta),r.*cos(theta),abs(s));

    for j = 1:targetsN

       plot(ax1,trueRange(i*signalN*NPulses,1,j),trueRange(i*signalN*NPulses,2,j),...
           'o','MarkerSize',5,'MarkerFaceColor','red','MarkerEdgeColor','black');
    end
    view(0, 90)
    set(h,'edgecolor','none');
    axis(ax1,[-80 80    0  100])
    view(0, 90)
    t03  = tic; 
     temp2 = obj.dopplerOnly(i);
     t3 = toc(t03); 
    s3(:,i) = reshape(temp2(1,1,:),NPulses,1); 
    time_span = 0:obj.tc*NPulses*txN:...
        obj.tc*NPulses*(Ncycles-1)*txN;     
    [x,y] = meshgrid(time_span(1:1:end),r2(1,:));

    

    h3 = pcolor(ax3,x,y,abs(s3(:,1:1:end))); 
        caxis([0,5000]); 
        %pcolor(ax3,v,r2,abs(temp));
    %axis(ax3,[-15  15 0 4])
    %set(h3,'edgecolor','none'); 
    set(h3,'edgecolor','none');
    
    
    
    
    
   
    pcolor(ax2,v,r2,abs(temp));
    for j = 1:targetsN
        range = sqrt(trueRange(i*signalN*NPulses,1,j)^2+trueRange(i*signalN*NPulses,2,j)^2);
        plot(ax2,range,trueRange(i*signalN*NPulses,4,j),...
            'o','MarkerSize',5,'MarkerFaceColor','red','MarkerEdgeColor','black');
    end
    axis(ax2,[0 80  -15  15])
 

    
    
   


    pause(0.00000001); 

    str = ['Time =',num2str(obj.timeData(i*obj.Ns*NPulses*txN)),'s'];
    str2 = ['Range-Doppler Processing Time = ',num2str(t1), ' s'];
    str3 = ['Range-Doppler Processing Time =',num2str(t2), ' s'];
    str4 = ['Doppler-Time Processing Time =',num2str(t3), ' s'];
    txt.set('String',str);
    txt2.set('String',str2);
    txt3.set('String',str3);
    txt4.set('String',str4);
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