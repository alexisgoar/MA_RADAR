function start(obj)
set(0,'DefaultFigureWindowStyle','docked');
f = figure('Visible','off');
%Close btn
btn = uicontrol('Style','pushbutton','String','Stop',...
    'Position',[20 780 100 40],...
    'Callback',@terminate);
%time indicator 

f.Visible = 'on';
t = 0; 
[s,r,t] = obj.rangeAzimuth(); 
while t <10000
        hold on; 
        s = obj.rangeAzimuth(); 
        % Draw Surface

        h = pcolor(r.*sin(t),r.*cos(t),abs(s)); 
               view(0, 90)
           set(h,'edgecolor','none');
                   plot_setup(obj.signal); 
        axis([-80 80    -1  100])     
        view(0, 90)% Set ‘axis’ For All Plots
        drawnow                                     % Draw Plot
        pause(0.1)       
        obj.signal.nextTimeStep();% Create Evenly-Timed Steps For Animation
        t = t +0.0000001; 
end






    function terminate(source,event)
        t =10001;
        close(f)
        error('Process terminated by the user');
        
    end







end