% Third version of the signal class to include optimzed signal generation 
% NOTE: For now, target positions are updated once per pulse, i.e. once
% every tx.tchirp s (Stop and Go approximation) 

classdef signal < handle
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
        %time keeper 
        time    
        %time for hands
        time2
    end
    properties (Constant)
        % For Doppler Range
        NPulses = 120; 
        % Noise 
        snr = 5; 
    end

    methods
        % constructor function
        function obj = signal(txarray,rxarray,varargin)
            txN = txarray.numberofElements; 
            rxN = rxarray.numberofElements; 
            targetn = size(varargin,2); 
            obj.numberofTargets = targetn; 
            
            obj.tx = txarray; 
            obj.rx = rxarray; 
            for i = 1:targetn
                 target_array(i) = varargin{i}; 
            end
            obj.target = target_array;
            % Build the initial deltaT matrix 
            obj.deltaT = zeros(txN,rxN,targetn); 
            for txi = 1:txN
                for rxj = 1:rxN
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
            %time init
            obj.time = 0; 
            %time two is used for testing micro doppler spectra
            obj.time2 = 0; 
        end
%----------Received Signal Generation ----------------------------------%
        % Optimized function of the received signal, the output is a matrix
        % contaning the received signal during a single chirp for all
        % targets, trasnmitters and receivers 
        % Note: for Doppler, it seems that for the doppler part of the
        % phase, the global time has to be used, while for the rest the
        % phase is 'reset' at the beginning of every pulse 
        function [s,timeStamp,d] = rxSignal(obj) 
            %init 
            txN = obj.tx.numberofElements; 
            rxN = obj.rx.numberofElements; 
            targetN = obj.numberofTargets; 
            signalN = obj.tx.samplesPerChirp*txN;
            timeStamp = 0:obj.tx.samplingRate:(obj.tx.samplingRate*(signalN-1));
            time_points =  reshape(repmat(timeStamp,txN*rxN,1),txN,rxN,signalN); 
            gtime_points = time_points+obj.time; 
            s = zeros(size(time_points)); 
            %calculate the signal 
            for i = 1:targetN 
                delay = repmat(obj.deltaT(:,:,i),1,1,signalN);
                noise = 1/(obj.snr)*randn(txN,rxN,signalN); 
                t = time_points+delay; 
                t1 = 2*pi*obj.tx.k*delay.*t; 
                t2 = -pi*obj.tx.k*delay.*delay; 
                t3 = 2*pi*obj.tx.frequency*delay; 
                %Doppler frequency 
                vr = obj.target(i).rangerate();
                fd = -2*vr/obj.tx.lambda;
                t4 = -2*pi*fd.*(gtime_points);
                %add all contributions
                s = s+exp(1i*(t1+t2+t3+t4))+noise; 
            end
            %Prepare the signal for export 
            signal = zeros(size(time_points)); 
            for i=1:txN 
               index = (1+(i-1)*obj.tx.samplesPerChirp):1:i*obj.tx.samplesPerChirp; 
               signal(i,:,index) =  s(i,:,index); 
            end
            s = signal;             
        end 
%---------------Build Data cube in dimensions tx, rx and time-------------%
        function [s,timeStamp,d] = dataCube(obj,flag)
            %init; 
            txN = obj.tx.numberofElements; 
            rxN = obj.rx.numberofElements;
            signalN = obj.tx.samplesPerChirp*txN;
            s=zeros(txN,rxN,signalN*obj.NPulses);
            timeStamp = zeros(signalN*obj.NPulses,1);
            %True ranges for plotting
            d=zeros(signalN*obj.NPulses,4,obj.numberofTargets); 
            %Concatenate data from all pulses 
           for i = 1:obj.NPulses
               index = ((i-1)*signalN+1):1:i*signalN;
               [s(:,:,index),t] = obj.rxSignal();
               timeStamp(index) = t+i*obj.tx.tchirp*txN;
               if nargin == 2
                     range = zeros(signalN,4,obj.numberofTargets);
                   for j = 1:obj.numberofTargets
                    
                      temp = [obj.target(j).x,obj.target(j).y,obj.target(j).z,obj.target(j).rangerate()];
                      range(:,:,j) = repmat(temp,signalN,1);
                   end
                d(index,:,:) = range;  
               end
               obj.nextPulse(); 
               obj.resetTime(); 
           end   
        end
       
            
        
        %Assumes that the elements of both receiver and transmitter are the
        %same for the y and z components
        function sM = steeringVectorMatrix(obj,theta)
           sM = exp(-1i*4*pi*obj.x_ij*sin(theta)/obj.tx.lambda);  
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
        
        function nextPulse(obj) 
            obj.time = obj.time + obj.tx.tchirp*obj.tx.numberofElements; 
            obj.time2 = obj.time2 + obj.tx.tchirp*obj.tx.numberofElements;
            for targeti = 1:obj.numberofTargets
                obj.target(targeti).move(obj.tx.tchirp*obj.tx.numberofElements);
                %For hands
                if obj.target(targeti).accel == 1
                    obj.target(targeti).vx = obj.target(targeti).vx0 + 4*cos(obj.time2*10);              
                end
            end

            obj.update_deltaT();
        end
        
        function resetTime(obj)
            obj.time = 0; 
        end
        
    end
    
    
end
