classdef signalProcessing 
   properties 
       signal
   end
   properties (Constant)
       % For Azimuth Profile
       theta = [-90:1:90]*pi/180; 
   end
   methods
       % Constructor function  
       function obj = signalProcessing(signal)
           obj.signal = signal; 
       end
%-----------------Ranging------------------------------------------------%
       function [s,R] = ranging(obj)
           %init
           Ns = obj.signal.tx.samplesPerChirp;
           sR = obj.signal.tx.samplingRate; 
           rxN = obj.signal.rx.numberofElements; 
           txN = obj.signal.tx.numberofElements;
           c = obj.signal.tx.c; 
           k = obj.signal.tx.k; 
           s_t = zeros(1,rxN,Ns); 
           % signal generation
           signal_time = obj.signal.rxSignal();
           % signal selection 
           for txi = 1:txN
              s_t(txi,:,:) = signal_time(txi,:,(1+(txi-1)*Ns):1:txi*Ns); 
           end
           %fast time fft 
           s = fft(s_t,[],3);
           %variables for plotting 
           freq =0:1/(sR*Ns):(Ns-1)/(Ns*sR);
           R = c*freq/(k*2);
       end
%---------- Range and Azimuth Profile------------------------------------%
       function [sout,R_plot,theta_plot] = rangeAzimuth(obj)
           %init
           sR = obj.signal.tx.samplingRate;
           rxN = obj.signal.rx.numberofElements;
           txN = obj.signal.tx.numberofElements;
           Ns = obj.signal.tx.samplesPerChirp*txN;
           c = obj.signal.tx.c;
           k = obj.signal.tx.k;
           thetaN = size(obj.theta,2);
           %signal generation 
           [signal_time] = obj.signal.rxSignal();
           %fast time fft 
           s = fft(signal_time,[],3);
           % Multiplication with steering vectors           
           sout = zeros(thetaN,Ns);
           for thetai = 1:thetaN 
              sM = obj.signal.steeringVectorMatrix(obj.theta(thetai));
              sM = repmat(sM,1,1,Ns); 
              s1 = s.*sM;
              s1 = sum(s1,1); 
              s1 = sum(s1,2); 
              sout(thetai,:) = reshape(s1,1,Ns); 
           end
           %variables for plotting 
           freq =0:1/(sR*Ns):(Ns-1)/(Ns*sR);
           R = c*freq/(k*2);
           [R_plot,theta_plot] = meshgrid(R,obj.theta); 
       end       
%-----------Doppler Ranging---------------------------------------------% 
       function [s,v_plot,R_plot] = dopplerRange(obj)
           %init 
           NPulses = obj.signal.NPulses;
           txN = obj.signal.tx.numberofElements;
           signalN = obj.signal.tx.samplesPerChirp*txN;
           sR = obj.signal.tx.samplingRate;
           tc = obj.signal.tx.tchirp; 
           c = obj.signal.tx.c;
           k = obj.signal.tx.k;
           ld = obj.signal.tx.lambda; 
           %signal generation 
           s = obj.signal.dataCube();
           %fast time fft 
           for i = 1:NPulses
               index = ((i-1)*signalN+1):1:i*signalN;
               s(:,:,index) = fft(s(:,:,index),[],3); 
           end
           %slow time fft 
           for i = 1:signalN
               index = i:(signalN):NPulses*signalN;
               s(:,:,index) = fftshift(fft(s(:,:,index),[],3),3); 
           end
           % variables for plotting           
           freqRange =0:1/(sR*signalN):(signalN-1)/(signalN*sR);
           R = c*freqRange/(k*2);
           freqDopp = -(NPulses-1)/(2*NPulses*tc):1/(tc*NPulses):(NPulses-1)/(2*NPulses*tc);
           V = freqDopp*ld/4;
           [v_plot,R_plot] =meshgrid(V,R); 
       end
   end 
end