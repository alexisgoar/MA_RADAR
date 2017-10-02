%Plots the frequency of the received signal after considering all delays
%for one transmitter, one receiver and one target
function s = plot_rxSignal(obj,txi,rxi,NPulses)
i = 1;
while obj.tx.chirpi < NPulses
    for j = 1:size(obj.target,2)
        freq(i,j) = rxSignal(obj,obj.tx.time,txi,rxi,j);
    end 
    timeStamp(i) = obj.tx.time;
    obj.tx.nextStep();
    i = i+1;
end

for j = 1:size(obj.target,2)
    h = plot(timeStamp,freq(:,j));
end

end