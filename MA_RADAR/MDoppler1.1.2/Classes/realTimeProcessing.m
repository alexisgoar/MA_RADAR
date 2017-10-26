% Contrary to the signalProcessing class, this class performs the signal
% processing without generating the signal data itself. Instead, the signal
% is loaded from a .mat file 

classdef realTimeProcessing
   properties 
       signalData
       timeData
       rangeData
       % Information about the signal-------------------------------------
       %Samples per chirp
       Ns
       %samplingRate
       sR 
       %NumberofElements
       rxN
       txN 
       %K
       k
       %chirp duration 
       tc
       %lambda
       lambda 
       %Number of Pulses
       NPulses
       %------------------------------------------------------------------
       % Information for signal processing--------------------------------
       theta
       steeringVectorMatrix
       %------------------------------------------------------------------
       R_plot; 
   end
   properties (Constant)
       %Physical Constants 
       c = 299792458;
   end
   methods
       % Constructor function  
       function obj = realTimeProcessing(data)
           obj.signalData =data.signal; 
           obj.timeData = data.time;
           obj.rangeData = data.trueRange; 
           %Information about the signal           
           obj.txN = size(data.signal,1); 
           obj.rxN = size(data.signal,2); 
           obj.Ns = data.Ns; 
           obj.sR = data.sR;
           obj.k = data.k; 
           obj.tc = data.tc; 
           obj.lambda = data.lambda; 
           obj.NPulses = data.NPulses; 
           %Information for Signal Processing
           obj.theta = data.theta; 
           obj.steeringVectorMatrix = data.steeringVectorMatrix; 
           % For tracking
           freq =0:1/(obj.sR*obj.Ns):(obj.Ns-1)/(obj.Ns*obj.sR);
           obj.R_plot = obj.c*freq/(obj.k*2);
       end
       % TO BE CHANGED SO THAT IT CAN BE DONE IN REAL TIME!
       function [s,R] = ranging(obj,i)
           Nts = obj.Ns; 
           signal_time = obj.signalData(:,:,1:Nts,i); 
           s = fft(signal_time,[],3)/size(signal_time,3);           
           freq =0:1/(obj.sR*Nts):(Nts-1)/(Nts*obj.sR);
           R = obj.c*freq/(obj.k*2);
          end
%-----------Range and Azimuth profile------------------------------------%
       function [sout,R_plot,theta_plot] = rangeAzimuth(obj,i)
           %Init
           Nts = obj.Ns; 
           thetaN = size(obj.theta,2);
           %Signal selection         

           %[signal_time2] = obj.signalData(:,:,(Nts+1):2*Nts,i);
           % Fast time fft 
           %s = fft(signal_time,[],3);
           %s2 = fft(signal_time2,[],3);

           % Multiplication with steering vectors 
         
           for txi = 1:obj.txN
               [signal_time] = obj.signalData(:,:,((txi-1)*Nts+1):txi*Nts,i);
               s = fft(signal_time,[],3)/size(signal_time,3);
               sout = zeros(thetaN,Nts);
           for thetai = 1:thetaN 
              sM = obj.steeringVectorMatrix(:,:,thetai);
              sM = repmat(sM,1,1,Nts); 
              s1 = s.*sM; 
              s1 = sum(s1,1); 
              s1 = sum(s1,2); 
              sout_temp(thetai,:) = reshape(s1,1,Nts); 
           end
          sout = sout + sout_temp; 
          sout = sout/(obj.txN*obj.rxN); 
           
           end 
           %Variables for plotting          
           freq =0:1/(obj.sR*Nts):(Nts-1)/(Nts*obj.sR);
           R = obj.c*freq/(obj.k*2);
           [R_plot,theta_plot] = meshgrid(R,obj.theta); 
       end
%------Doppler Ranging--------------------------------------------------%
       function [s,v_plot,R_plot] = dopplerRange(obj,i)
           %init
           signalN = obj.Ns;
           %signl selection
           s  = obj.signalData(:,:,:,i); 
           %fast time fft                 
           for i = 1:obj.NPulses
               index = ((i-1)*signalN+1):1:i*signalN;
               s(:,:,index) = fft(s(:,:,index),[],3); 
           end
           %slow time fft
           for i = 1:signalN
               index = i:(signalN*obj.txN):obj.NPulses*signalN*obj.txN;
               s(:,:,index) = fftshift(fft(s(:,:,index),[],3),3); 
           end
           %variables for plotting
           freqRange =0:1/(obj.sR*signalN):(signalN-1)/(signalN*obj.sR);
           R = obj.c*freqRange/(obj.k*2);
           freqDopp = -(obj.NPulses-1)/(2*obj.NPulses*obj.tc):1/(obj.tc*obj.NPulses):(obj.NPulses-1)/(2*obj.NPulses*obj.tc);
           V = freqDopp*obj.lambda/4;
           [v_plot,R_plot] =meshgrid(V,R); 
       end
 %-----For Doppler vs Time Plot------------------------------------------%
       function [s] = dopplerOnly(obj,i) 
           %init
           signalN = obj.Ns;
           %signal selection 
           signal  = obj.signalData(:,:,:,i);
           %slow time fft 
           s = zeros(obj.txN,obj.rxN,obj.NPulses); 
           for i = 1:signalN 
               index = i:(signalN*obj.txN):obj.NPulses*signalN*obj.txN;
               temp = fftshift(fft(signal(:,:,index),[],3),3); 
               s = s + abs(temp); 
           end         
       end
       %--------------- Detection algorithms ---------------------------------%
       function [index] = detectRange(obj,st)
           Nts = obj.Ns; 
           st = reshape(st(1,1,:),1,Nts); 
           [a,b] = findpeaks(abs(st));
           detection = a > 0.1; 
           index = b(detection); 
       end
       function [out] = detectAzimuth(obj,signal,index_r)
           st = signal(:,index_r);
           counter = 1; 
           if isempty(index_r) == 0  
           for i = 1:max(size(index_r))
               [a,b] = findpeaks(abs(st(:,i)));
               detection = a >0.1;
               index = find(detection);

               if size(index,1) > 0
                   for j = 1:max(size(index))
                       out(counter,:) = [index_r(i),b(index(j))];
                       counter = counter+1;
                   end
               end
           end
           if exist('out') == 0
              out = [];  
           end
           else
               out = []; 
           end
       end 
       function [out] = detectDoppler(obj,signal,index_r)
           st = signal(index_r,:);
           counter = 1;
           if isempty(index_r) == 0 
           for i = 1:max(size(index_r))
               [a,b] = findpeaks(abs(st(i,:)));
               detection = a >750;
               index = find(detection);
               
               if size(index,1) > 0
                   for j = 1:max(size(index))
                       out(counter,:) = [index_r(i),b(index(j))];
                       counter = counter+1;
                   end
               end
           end
           else
               out = []; 
           end
           
       end
%---------------------------Functions for Tracking--------------------%
       function [out] = detectAzimuth2(obj,signal,index_r)
           st = signal(:,index_r);
           counter = 1; 
           if isempty(index_r) == 0 
           for i = 1:max(size(index_r))
               [a,b] = findpeaks(abs(st(:,i)));
               detection = a >0.07;
               index = find(detection);

               if size(index,1) > 0
                   for j = 1:max(size(index))
                       out_index(counter,:) = [index_r(i),b(index(j))];
                       az_index(counter) = b(index(j)); 
                       index_r2(counter) = index_r(i); 
                       counter = counter+1;
                   end
                  
               end
           end
           if exist('out_index') == 0
               out = []; 
               return; 
           end
           N = size(out_index,1);
           
           for j = 1:N
               out(1,j) = obj.R_plot(index_r2(j)) *sin(obj.theta(az_index(j))); 
               out(2,j) =  obj.R_plot(index_r2(j)) *cos(obj.theta(az_index(j))); 
           end
           else
               out = []; 
           end
       end 
%------------Kalman Filter -------------------------------------------%
       function [X,P] = kalmanF(obj,zk,X,P,deltaT)
           %extract
           z = [zk(1)*sin(zk(2));zk(1)*cos(zk(2))];
           R = [0.5^2,0;0,0.5^2];
           %Observation Matrix
           H = [1,0,0,0;0,1,0,0];
           
           %State transition matrix
           A = [1 0 deltaT 0
               0 1 0 deltaT
               0 0 1 0
               0 0 0 1];
           %State Prediction
           X = A*X;
           %Error Covariance Prediction
           P = A*P*transpose(A);
           %Weights
           K = P*transpose(H)/(H*P*transpose(H)+R);
           %New estimates
           X = X + K*(z-H*X);
           %X = X + K*(z-H*X);
           %Error Covariance
            P = P -K*H*P; 

       end
       
       
       
       
   end
end