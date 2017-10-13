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
       end
       % TO BE CHANGED SO THAT IT CAN BE DONE IN REAL TIME!
       function [s,R] = ranging(obj)
           %signal_time = obj.signal.rxSignal(); 
           %s_t = zeros(1,obj.rxN,obj.Ns); 
           %for txi = 1:obj.txN
           %   s_t(txi,:,:) = signal_time(txi,:,(1+(txi-1)*obj.Ns):1:txi*obj.Ns); 
           %end
           %s = fft(s_t,[],3);           
           %freq =0:1/(obj.sR*obj.Ns):(obj.Ns-1)/(obj.Ns*obj.sR);
           %R = obj.c*freq/(obj.k*2);
       end
%-----------Range and Azimuth profile------------------------------------%
       function [sout,R_plot,theta_plot] = rangeAzimuth(obj,i)
           %Init
           Nts = obj.Ns*obj.txN; 
           thetaN = size(obj.theta,2);
           %Signal selection         
           [signal_time] = obj.signalData(:,:,1:Nts,i); 
           % Fast time fft 
           s = fft(signal_time,[],3);
           % Multiplication with steering vectors 
           sout = zeros(thetaN,Nts);
           for thetai = 1:thetaN 
              sM = obj.steeringVectorMatrix(:,:,thetai);
              sM = repmat(sM,1,1,Nts); 
              s1 = s.*sM;
              s1 = sum(s1,1); 
              s1 = sum(s1,2); 
              sout(thetai,:) = reshape(s1,1,Nts); 
           end
           %Variables for plotting          
           freq =0:1/(obj.sR*Nts):(Nts-1)/(Nts*obj.sR);
           R = obj.c*freq/(obj.k*2);
           [R_plot,theta_plot] = meshgrid(R,obj.theta); 
       end
%------Doppler Ranging--------------------------------------------------%
       function [s,v_plot,R_plot] = dopplerRange(obj,i)
           %init
           signalN = obj.Ns*obj.txN;
           %signl selection
           s  = obj.signalData(:,:,:,i); 
           %fast time fft                 
           for i = 1:obj.NPulses
               index = ((i-1)*signalN+1):1:i*signalN;
               s(:,:,index) = fft(s(:,:,index),[],3); 
           end
           %slow time fft
           for i = 1:signalN
               index = i:(signalN):obj.NPulses*signalN;
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
           signalN = obj.Ns*obj.txN;
           %signal selection 
           signal  = obj.signalData(:,:,:,i);
           %slow time fft 
           s = zeros(obj.txN,obj.rxN,obj.NPulses); 
           for i = 1:signalN 
               index = i:(signalN):obj.NPulses*signalN;
               temp = fftshift(fft(signal(:,:,index),[],3),3); 
               s = s + abs(temp); 
           end         
       end
   end 
end