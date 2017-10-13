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
       % Ranging
       function [s,R] = ranging(obj)
           Ns = obj.signal.tx.samplesPerChirp;
           sR = obj.signal.tx.samplingRate; 
           rxN = obj.signal.rx.numberofElements; 
           txN = obj.signal.tx.numberofElements;
           signal_time = obj.signal.rxSignal(); 
           c = obj.signal.tx.c; 
           k = obj.signal.tx.k; 
           s_t = zeros(1,rxN,Ns); 
           for txi = 1:txN
              s_t(txi,:,:) = signal_time(txi,:,(1+(txi-1)*Ns):1:txi*Ns); 
           end
           s = fft(s_t,[],3);
           
           freq =0:1/(sR*Ns):(Ns-1)/(Ns*sR);
           R = c*freq/(k*2);
       end
       % Range and Azimuth
       function [sout,R_plot,theta_plot] = rangeAzimuth(obj)

           sR = obj.signal.tx.samplingRate;
           rxN = obj.signal.rx.numberofElements;
           txN = obj.signal.tx.numberofElements;
           Ns = obj.signal.tx.samplesPerChirp*txN;
           c = obj.signal.tx.c;
           k = obj.signal.tx.k;
           thetaN = size(obj.theta,2);
           
           [signal_time] = obj.signal.rxSignal();
           
           s = fft(signal_time,[],3);
           
           freq =0:1/(sR*Ns):(Ns-1)/(Ns*sR);
           R = c*freq/(k*2);
           
           sout = zeros(thetaN,Ns);
           for thetai = 1:thetaN 
              sM = obj.signal.steeringVectorMatrix(obj.theta(thetai));
              sM = repmat(sM,1,1,Ns); 
              s1 = s.*sM;
              s1 = sum(s1,1); 
              s1 = sum(s1,2); 

              sout(thetai,:) = reshape(s1,1,Ns); 
           end
 
           %figure; 
           
           %hold on; 
           [R_plot,theta_plot] = meshgrid(R,obj.theta); 
           %h = pcolor(R_plot.*sin(theta_plot),R_plot.*cos(theta_plot),abs(sout)); 
           %view(0, 90)
           %set(h,'edgecolor','none');
           
       end
       
       %Doppler Ranging 
       
       
       
       %Plotting functions  
   end 
end