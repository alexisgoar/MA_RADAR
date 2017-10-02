% Function used by class txarray to plot a sent signal
% For one receiver only 
%obj must me a txarray class
function h = plot_txSignal(obj,txi,NPulses)
i = 1;
while obj.chirpi < NPulses
    freq(i) = txSignal(obj,txi,obj.time);
    timeStamp(i) = obj.time;
    obj.nextStep();
    i = i+1;
end
h = plot(timeStamp,freq);
end