
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
        function deltaT = deltaT(obj,txi,rxj,k)
            
            deltaX = obj.target(k).x-obj.rx.xE(rxj)+...
                obj.target(k).x - obj.tx.xE(txi);
            deltaY = obj.target(k).y-obj.rx.yE(rxj)+...
                obj.target(k).y - obj.tx.yE(txi);
            deltaZ = obj.target(k).z-obj.rx.zE(rxj)+...
                obj.target(k).z - obj.tx.zE(txi);
            delta = [deltaX,deltaY,deltaZ];
            deltaT = norm(delta)/(obj.tx.c);
        end
       
        % Testing
        function deltaT2 = deltaT2(obj,txi,rxj,k)
            R = [obj.target(k).x,obj.target(k).y,obj.target(k).z]; 
            xTx = [obj.tx.xE(txi),obj.tx.yE(txi),obj.tx.zE(txi)];  
            xRx = [obj.rx.xE(rxj),obj.rx.yE(rxj),obj.tx.zE(rxj)]; 
            xij = (xTx+xRx)/2; 
            R = 2*(R-xij); 
            R = norm(R); 
            deltaT2 = R/(obj.tx.c); 
            
            
        end
        
        % General next time function
        function nextTimeStep(obj)
            obj.tx.nextStep_sampling(); 
            targetn = size(obj.target,2);
            for targeti = 1:targetn
               obj.target(targeti).move(obj.tx.samplingRate);  
            end
        end

        % calculates the received signal after mixing it with a local
        % copy of the singal  for a single target
        function s = receivedSignal(obj,t,txi,rxi,targeti)
            t1 = 2*pi*obj.tx.k*obj.deltaT(txi,rxi,targeti)*t;
            t2 = -pi*obj.tx.k*(obj.deltaT(txi,rxi,targeti)^2);
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
        % Function to calculate the received signal for a dynamic scatterer
        function s = rxSignal3(obj,time,txi,rxi,targeti)            
            % Doppler Frequency
            vr = obj.target(targeti).rangerate();
            fd = -2*vr/obj.tx.lambda;
            
            delay = obj.deltaT(txi,rxi,targeti);
            time = time-delay;
            flag = obj.tx.tx_flags(time,txi);
            t1 = 2*pi*obj.tx.k*delay*time;
            t2 = -pi*obj.tx.k*delay^2;
            t3 = 2*pi*(obj.tx.frequency+fd)*delay;
            t4 = -2*pi*fd*(time); 

            s = exp(1i*(t1+t2+t3+t4))*flag;
        end
       
        % Functions used to calculate the Azimuth Range
        
        function s = steeringVector(obj,theta,txi,rxi)
           x_tx = [obj.tx.xE(txi),obj.tx.yE(txi),obj.tx.zE(txi)]; 
           x_rx = [obj.rx.xE(rxi),obj.rx.yE(rxi),obj.rx.zE(rxi)]; 
           xij = norm((x_tx+x_rx)/2); 
           s = exp(1i*4*pi*xij*sin(theta)/obj.tx.lambda);  
        end
        
        % Functions used to calculate Range rate
        
        function s = rangerateEstimator(obj,range_rate)
           arg = 4*pi*range_rate/obj.tx.lambda; 
           s = exp(-1i*arg); 
        end


    end
    
    
end
