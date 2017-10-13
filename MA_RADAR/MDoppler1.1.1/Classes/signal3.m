% Third version of the signal class to include optimzed signal generation 

classdef signal3 < handle
    properties 
        % transmit array class
        tx 
        % receive array class
        rx
        % target
        target
        numberofTargets
        % delay time for each target,transmitter and receiver
        deltaT 
        % xij for construction of steering vectors 
        x_ij
    end

    methods
        % constructor function
        function obj = signal3(txarray,rxarray,varargin)
            txn = txarray.numberofElements; 
            rxn = rxarray.numberofElements; 
            targetn = size(varargin,2); 
            obj.numberofTargets = targetn; 
            
            obj.tx = txarray; 
            obj.rx = rxarray; 
            for i = 1:targetn
                 target_array(i) = varargin{i}; 
            end
            obj.target = target_array;
            
            obj.deltaT = zeros(txn,rxn,targetn); 
            
            for txi = 1:txn
                for rxj = 1:rxn
                    for k = 1:targetn
                        deltaX = obj.target(k).x-obj.rx.xE(rxj)+...
                            obj.target(k).x - obj.tx.xE(txi);
                        deltaY = obj.target(k).y-obj.rx.yE(rxj)+...
                            obj.target(k).y - obj.tx.yE(txi);
                        deltaZ = obj.target(k).z-obj.rx.zE(rxj)+...
                            obj.target(k).z - obj.tx.zE(txi);
                        delta = [deltaX,deltaY,deltaZ];
                        obj.deltaT(txi,rxj,k) = norm(delta)/(obj.tx.c);
                    end
                end
            end
            
            %for construction of the steering vectors 
            txN = obj.tx.numberofElements;
            rxN = obj.rx.numberofElements;
            x_tx = zeros(1,txN); 
            x_rx = zeros(1,rxN); 
            for txi = 1:txN
                x_tx(txi) = obj.tx.xE(txi);
            end
            for rxi = 1:rxN
                x_rx(rxi) = obj.rx.xE(rxi);
            end
            
            x_tx = reshape(repmat(x_tx,1,rxN),txN,rxN);
            x_rx = reshape(repmat(x_rx,txN,1),txN,rxN);
            
            obj.x_ij = abs(x_tx+x_rx)/2;
            
        end
        % Optimized function of the received signal, the output is a matrix
        % contaning the received signal during a single chirp for all
        % targets, trasnmitters and receivers 
        % NOT ENABLED FOR MOVING TARGETS FOR NOW (Calculation of Delta T
        % not optimized yet) 
        function [s,timeStamp] = rxSignal(obj) 
            txN = obj.tx.numberofElements; 
            rxN = obj.rx.numberofElements; 
            targetN = obj.numberofTargets; 
            signalN = obj.tx.samplesPerChirp*txN;
            
            timeStamp = 0:obj.tx.samplingRate:(obj.tx.samplingRate*(signalN-1));
            time =  reshape(repmat(timeStamp,txN*rxN,1),txN,rxN,signalN); 
     
            s = zeros(size(time)); 
            for i = 1:targetN 
                delay = repmat(obj.deltaT(:,:,i),1,1,signalN);
                t = time+delay; 
                t1 = 2*pi*obj.tx.k*delay.*t; 
                t2 = -pi*obj.tx.k*delay.*delay; 
                t3 = 2*pi*obj.tx.frequency*delay; 
                s = s+exp(1i*(t1+t2+t3)); 
            end
            signal = zeros(size(time)); 

            for i=1:txN 
               index = (1+(i-1)*obj.tx.samplesPerChirp):1:i*obj.tx.samplesPerChirp; 
               signal(i,:,index) =  s(i,:,index); 
            end
            s = signal;     
            
            
        end 
       
        % Functions used to calculate the Azimuth Range
        
        function s = steeringVector(obj,theta,txi,rxi)
           x_tx = [obj.tx.xE(txi),obj.tx.yE(txi),obj.tx.zE(txi)]; 
           x_rx = [obj.rx.xE(rxi),obj.rx.yE(rxi),obj.rx.zE(rxi)]; 
           xij = norm((x_tx+x_rx)/2); 
           s = exp(1i*4*pi*xij*sin(theta)/obj.tx.lambda);  
        end
        
        %Assumes that the elements of both receiver and transmitter are the
        %same for the y and z components
        function sM = steeringVectorMatrix(obj,theta)
           sM = exp(1i*4*pi*obj.x_ij*sin(theta)/obj.tx.lambda);  
        end
        %%%% TIME FUNCTIONS %%%%%%
        function update_deltaT(obj)
            txn = obj.tx.numberofElements;
            rxn = obj.rx.numberofElements;
            targetn = obj.numberofTargets; 
            for txi = 1:txn
                for rxj = 1:rxn
                    for k = 1:targetn
                        deltaX = obj.target(k).x-obj.rx.xE(rxj)+...
                            obj.target(k).x - obj.tx.xE(txi);
                        deltaY = obj.target(k).y-obj.rx.yE(rxj)+...
                            obj.target(k).y - obj.tx.yE(txi);
                        deltaZ = obj.target(k).z-obj.rx.zE(rxj)+...
                            obj.target(k).z - obj.tx.zE(txi);
                        delta = [deltaX,deltaY,deltaZ];
                        obj.deltaT(txi,rxj,k) = norm(delta)/(obj.tx.c);
                    end
                end
            end   
        end
        
        function nextTimeStep(obj)
            obj.tx.nextStep_sampling();
            targetn = size(obj.target,2);
            for targeti = 1:targetn
                obj.target(targeti).move(obj.tx.samplingRate);
            end
            
            obj.update_deltaT();

        end
        
    end
    
    
end
