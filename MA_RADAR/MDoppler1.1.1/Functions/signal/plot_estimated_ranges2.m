%plots the estimated range for all possible paths
% for a single target
function plot_estimated_ranges2(obj,NPulses)
figure;
set(0,'DefaultFigureWindowStyle','docked');
hold on;
%  subplot(obj.tx.numberofElements*obj.rx.numberofElements,1,1);
txn = obj.tx.numberofElements;
rxn = obj.rx.numberofElements;
for i = 1:txn
    for j = 1:rxn
        h = subplot(rxn,txn,i+(j-1)*txn);
        plot_estimated_range2(obj,i,j,NPulses);
        Txnum = ['Tx ',num2str(i)];
        Rxnum = [' Rx ',num2str(j)];
        title([Txnum,Rxnum]);
        set(gca,'ytick',[]);
        set(gca,'yticklabel',[]);
        obj.tx.resetTime(); 
    end
end
end