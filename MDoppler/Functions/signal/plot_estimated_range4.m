%Used optimized received signal
function s = plot_estimated_range4(obj)

[signal,timeStamp] = obj.rxSignal4();

N=size(timeStamp,2);
freq =0:1/(obj.tx.samplingRate*N):(N-1)/(N*obj.tx.samplingRate);
R = obj.tx.c*freq/(obj.tx.k*2);

figure;
set(0,'DefaultFigureWindowStyle','docked');
hold on;
%  subplot(obj.tx.numberofElements*obj.rx.numberofElements,1,1);
txn = obj.tx.numberofElements;
rxn = obj.rx.numberofElements;
for txi = 1:txn
    for rxi = 1:rxn
        h = subplot(rxn,txn,txi+(rxi-1)*txn);
        
        s_time = reshape(signal(txi,rxi,:),[],1);
        s_freq = fft(s_time);
        
        h = plot(R,abs(s_freq));
        Txnum = ['Tx ',num2str(txi)];
        Rxnum = [' Rx ',num2str(rxi)];
        title([Txnum,Rxnum]);
        set(gca,'ytick',[]);
        set(gca,'yticklabel',[]);
        obj.tx.resetTime();
    end
end
end










