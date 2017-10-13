function start(obj)
set(0,'DefaultFigureWindowStyle','docked');
f = figure('Visible','off');
%Close btn
btn = uicontrol('Style','pushbutton','String','Stop',...
    'Position',[20 780 100 40],...
    'Callback',@terminate);
%timer
str = ['Time =',num2str(obj.signal.time),'s'];
txt = uicontrol('Style','text',...
    'Position',[10 700 120 40],...
    'String',str);
% performance indicator
str2 = ['Range-Doppler Processing Time\n',num2str(0), ' s'];
txt2 = uicontrol('Style','text',...
    'Position',[10 680 120 40],...
    'String',str);

f.Visible = 'on';

txN = obj.signal.tx.numberofElements;
signalN = obj.signal.tx.samplesPerChirp*txN;
ax1 = axes('Position',[0.15 0.5 0.7 0.45]);
hold on;



ax2 = axes('Position',[0.15 0.05 0.7 0.35]);
hold on; 
t = 0;
[~,r,t_stamp] = obj.rangeAzimuth();
[~,r2,v] = obj.dopplerRange();
while t <10000
    cla(ax1)
    cla(ax2)
    tic;
    s = obj.rangeAzimuth();
    tc = toc;

    
    h = pcolor(ax1,r.*sin(t_stamp),r.*cos(t_stamp),abs(s));
    
    view(0, 90)
    set(h,'edgecolor','none');
    plot_setup(obj.signal,ax1);
    axis(ax1,[-80 80    0  100])
    view(0, 90)
                                     
    
    s2 = obj.dopplerRange();
    
    temp = reshape(s2(1,1,:),signalN,obj.signal.NPulses);
    
 
    pcolor(ax2,v,r2,abs(temp));
    axis(ax2,[0 80  -15  15])
           
    view(0, 90)
    set(h,'edgecolor','none');

    
    pause(0.00001)
    
    str = ['Time =',num2str(t),'s'];
    str2 = ['Range-Doppler Processing Time = ',num2str(tc), ' s'];
    txt.set('String',str);
    txt2.set('String',str2);
    t = t +obj.signal.tx.tchirp*obj.signal.NPulses;
end


    function terminate(source,event)
        t =10001;
        close(f)
        
    end


end