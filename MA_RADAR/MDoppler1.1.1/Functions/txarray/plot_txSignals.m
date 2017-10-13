% Function used by class txarray to plot a sent signal
% Plots all transmitters
%obj must me a txarray class
function h = plot_txSignals(obj,NPulses)
figure;
set(0,'DefaultFigureWindowStyle','docked');
hold on;
txn = obj.numberofElements;
for i = 1:txn
    h = subplot(txn,1,i);
    plot_txSignal(obj,i,NPulses);
    Txnum = ['Tx ',num2str(i)];
    title([Txnum]);
    set(gca,'ylim',[obj.frequency-obj.k*obj.tchirp,...
        obj.frequency+obj.k*obj.tchirp]);
    set(gca,'xlim',[obj.t0,obj.tchirp*NPulses]);
    obj.resetTime();
end
end