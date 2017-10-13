% function to plot the target per time
function animate(obj,tstep,tstart,tend,rx,tx)
if nargin == 4
    obj.move(tstart);
    time = tstart;
    while time < tend
        plot(obj);
        pause(0.05);
        time = time + tstep;
        obj.move(tstep);
    end
    % Animate target with antennas
elseif nargin == 6
    obj.move(tstart);
    time = tstart;
    while time < tend
        hold on;
        plot(rx);
        plot(tx);
        h1 = plot(obj);
        pause(0.05);
        
        time = time + tstep;
        obj.move(tstep);
        if time < tend
            delete(h1);
        end
    end
end
end