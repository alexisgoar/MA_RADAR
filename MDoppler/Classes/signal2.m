
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
            txN = obj.tx.numberofElements;
            rxN = obj.rx.numberofElements;
            targetN = size(obj.target,2);
            deltaT = zeros(txN,rxN,targetN);
            for i = 1:txN
                for j = 1:rxN
                    for k = 1:targetN
                        deltaX = obj.rx.xE(j) - obj.target(k).x - obj.tx.xE(i);
                        deltaY = obj.rx.yE(j) - obj.target(k).y - obj.tx.yE(i);
                        deltaZ = obj.rx.zE(j) - obj.target(k).z - obj.tx.zE(i);
                        delta = [deltaX,deltaY,deltaZ];
                        deltaT(i,j,k) = norm(delta)/obj.tx.c;
                    end
                end
            end
        end

        % calculates the received signal after mixing it with a local
        % copy of the singal  for a single target
        function s = receivedSignal(obj,t,txi,rxi,targeti)
            t1 = 2*pi*obj.tx.k*obj.deltaT(txi,rxi,targeti)*t;
            t2 = -pi*obj.tx.k*obj.deltaT(txi,rxi,targeti)^2;
            t3 = 2*pi*obj.tx.frequency*obj.deltaT(txi,rxi,targeti);
            s = exp(1i*(t1+t2+t3)); 
        end
        %Calculates the frequency of the received signal considering all
        %delays 
        function s = rxSignal(obj,time,txi,rxi,targeti)
            delay = obj.deltaT(txi,rxi,targeti);  
            time = time-delay; 
            s = obj.tx.txSignal(txi,time);
        end
        % Function to calculate the complete received signal for a static
        % scatterer 
        function s = rxSignal2(obj,time,txi,rxi,targeti)
            delay = obj.deltaT(txi,rxi,targeti);
            time = time-delay;
            flag = obj.tx.tx_flags(time,txi); 
            t1 = 2*pi*obj.tx.k*delay*time;
            t2 = -pi*obj.tx.k*delay^2;
            t3 = 2*pi*obj.tx.frequency*delay;
            s = exp(1i*(t1+t2+t3))*flag;
        end 


    end
    
    
end
