classdef signal < handle
    properties 
        tx 
        rx
        target
    end
    properties (Dependent)
        deltaT
    end
    methods
        function obj = signal(txarray,rxarray,target)
            obj.tx = txarray; 
            obj.rx = rxarray; 
            obj.target = target; 
        end
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
        function s = receivedSignal(obj,t,i,j)
            t1 = 2*pi*obj.tx.k*obj.deltaT(i,j)*t;
            t2 = -pi*obj.tx.k*obj.deltaT(i,j)^2;
            t3 = 2*pi*obj.tx.frequency*obj.deltaT(i,j);
            s = exp(1i*(t1+t2+t3)); 
        end
        function plotreceived(obj)
            numberofChirps = 1; 
            samplesperChirp = obj.tx.tchirp/obj.tx.samplingRate; 
            time = 0:obj.tx.tchirp/samplesperChirp:obj.tx.tchirp*numberofChirps;
            for i = 1:size(time,2)
                s = receivedSignal(obj,time,1,1); 
            end
            N=size(time,2);
            freq =0:1/(obj.tx.samplingRate*N):(N-1)/(N*obj.tx.samplingRate); 
            R = obj.tx.c*freq/(obj.tx.k); 
            sfd = fft(s);
            plot(R,abs(sfd)); 
        end
    end
    
    
end
