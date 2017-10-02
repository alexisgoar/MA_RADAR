%Plots the frequency of the received signal after considering all delays
%for one transmitter, one receiver and one target
function s = plot_rxSignals(obj,NPulses)
figure;
set(0,'DefaultFigureWindowStyle','docked');
hold on;
txn = obj.tx.numberofElements;
rxn = obj.rx.numberofElements;

for i = 1:txn
    for j = 1:rxn
        h = subplot(rxn,txn,i+(j-1)*txn);
        hold on;
        plot_rxSignal(obj,i,j,NPulses);
        obj.tx.resetTime();
        set(gca,'ylim',[obj.tx.frequency-obj.tx.k*obj.tx.tchirp,...
            obj.tx.frequency+obj.tx.k*obj.tx.tchirp]);
        set(gca,'xlim',[obj.tx.t0,obj.tx.tchirp*NPulses]);
        Txnum = ['Tx ',num2str(i)];
        Rxnum = [' Rx ',num2str(j)];
        title([Txnum,Rxnum]);
        set(gca,'ytick',[]);
        set(gca,'yticklabel',[]);
    end
end

s = 1; 
end