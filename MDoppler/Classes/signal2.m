% Extension class of the original signal class to allow for multiple
% targets
classdef signal2 < handle
    properties 
        % transmit array class
        tx 
        % receive array class
        rx
        % target: to be extended to multiple targets
        target
    end
    properties (Dependent)
        % timepath from all of the tx to the target and back to rx
        deltaT
    end
    methods
        % constructor function
        function obj = signal2(txarray,rxarray,varargin)
            obj.tx = txarray; 
            obj.rx = rxarray; 

            for i = 1:size(varargin,2)
                 target_array(i) = varargin{i}; 
            end
            obj.target = target_array; 
        end
        % get function of deltaT 
        function deltaT = get.deltaT(obj)
            deltaT = zeros(obj.tx.numberofElements,obj.rx.numberofElements);
            for i = 1:obj.tx.numberofElements
                for j = 1:obj.rx.numberofElements
                    deltaX = obj.rx.xE(j) - obj.target.x - obj.tx.xE(i);
                    deltaY = obj.rx.yE(j) - obj.target.y - obj.tx.yE(i);
                    deltaZ = obj.rx.zE(j) - obj.target.z - obj.tx.zE(i);
                    delta = [deltaX,deltaY,deltaZ];
                    deltaT(i,j) = norm(delta)/obj.tx.c;
                end
            end
        end
        % Plots the setup
        function plot_setup(obj)
            figure;
            hold on;
            plot(obj.tx); 
            plot(obj.rx); 
            size(obj.target,2);
            for i  = 1:size(obj.target,2)
                plot(obj.target(i));
            end
        end
        % calculates the received signal after mixing it with a local
        % copy of the singal 
        function s = receivedSignal(obj,t,txi,rxi)
            t1 = 2*pi*obj.tx.k*obj.deltaT(txi,rxi)*t;
            t2 = -pi*obj.tx.k*obj.deltaT(txi,rxi)^2;
            t3 = 2*pi*obj.tx.frequency*obj.deltaT(txi,rxi);
            s = exp(1i*(t1+t2+t3)); 
        end
        % plots the estimated range base on the received signal after
        % applying an FFT for transimeter txi and receiver rxi
        function h = plot_estimated_range(obj,txi,rxi)
            numberofChirps = 1; 
            samplesperChirp = obj.tx.tchirp/obj.tx.samplingRate; 
            time = 0:obj.tx.tchirp/samplesperChirp:obj.tx.tchirp*numberofChirps;
            for i = 1:size(time,2)
                s = receivedSignal(obj,time,txi,rxi); 
            end
            N=size(time,2);
            freq =0:1/(obj.tx.samplingRate*N):(N-1)/(N*obj.tx.samplingRate); 
            R = obj.tx.c*freq/(obj.tx.k); 
            sfd = fft(s);
            h = plot(R,abs(sfd)); 
        end
        %plots the estimated range for all possible paths 
        function plot_estimated_ranges(obj)
            figure;
            set(0,'DefaultFigureWindowStyle','docked');
            hold on; 
            %  subplot(obj.tx.numberofElements*obj.rx.numberofElements,1,1);
            txn = obj.tx.numberofElements;
            rxn = obj.rx.numberofElements;
            for i = 1:txn
                for j = 1:rxn
                    h = subplot(rxn,txn,i+(j-1)*txn);
                    obj.plot_estimated_range(i,j);
                    Txnum = ['Tx ',num2str(i)];
                    Rxnum = [' Rx ',num2str(j)]; 
                    title([Txnum,Rxnum]); 
                    set(gca,'ytick',[]);
                    set(gca,'yticklabel',[]);                
                end
            end
        end
    end
    
    
end
