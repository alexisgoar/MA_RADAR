% This is the same class as realTimeProcessing adapted for raw data from
% the ODR451
classdef realTimeProcessing_ODR451
   properties 
      % Signal Data 
      signalData; 
      % Number of... 
      numTxChannels; 
      numRxChannels; 
      nUp; 
      nCycles;
      B; 
      rLin;
      vLin; 
      thetaLin; 
      lambda; 
      steeringVector; 
   end
   properties (Constant)
       %Physical Constants 
       c = 29992458;
       nfft = 2048; 
       ntheta = 120; 
       fCenter = 79e9;
   end
   methods
       %% Constructor function
       function obj = realTimeProcessing_ODR451(input)
           obj.signalData = input.raw_data;
           obj.nUp = size(obj.signalData,1);
           obj.numTxChannels = size(obj.signalData,2);
           obj.numRxChannels = size(obj.signalData,3);
           obj.nCycles = size(obj.signalData,4);
           %obj.B = input.B;
           obj.B = 900e6;
           obj.rLin = linspace(0,obj.fCenter/obj.B,obj.nfft/2+1);
           obj.vLin = (linspace(-4,4,32)); 
           obj.thetaLin = linspace(-90,90,obj.ntheta)*pi/180; 
           obj.lambda =  obj.c/obj.fCenter;
           obj.steeringVector = zeros(obj.numRxChannels,obj.ntheta); 
           for i = 1:obj.numRxChannels
               for j = 1:obj.ntheta
                   obj.steeringVector(i,j) = exp(-1i*pi*(1-i)*sin(obj.thetaLin(j))); 
               end
           end
       end
       %% Ranging
       function s = range(obj,txi,rxi,cyclei)
           signal  = obj.signalData(:,txi,rxi,cyclei); 
           s = fft(signal,obj.nfft,1)./size(signal,1);
           s = s(1:end/2+1,:,:); 
       end
       %% Range Detection 
       function [index] = detectRange(obj,cyclei)
           s = obj.range(1,1,cyclei); 
           [a,b] = findpeaks(abs(s)); 
           detection = a> 0.10; 
           index = b(detection); 
       end
       %% Doppler Ranging 
       function s = dopplerRange(obj,rxi,cyclei) 
            %signal selection 
            s = obj.signalData(:,:,rxi,cyclei); 
            %fast time fft
            s = fft(s, obj.nfft,1)./size(s,1); 
            %slow time fft 
            s = fftshift(fft(s,32,2),2)./size(s,2); 
            s = s(1:end/2+1,:,:); 
       end
       %% Range Azimuth Profile
       function s_out = rangeAzimuth(obj,txi,cyclei) 
          %signal selection
          s = obj.signalData(:,txi,:,cyclei); 
          s = squeeze(s); 
          % range estimation 
          s = fft(s,obj.nfft,1)./size(s,1); 
          s = s(1:end/2+1,:,:); 
   
          %s_out init
          s_out = zeros(obj.nfft/2+1,obj.ntheta); 
          %Azimuth profile 
          for thetai = 1:obj.ntheta
             sV = obj.steeringVector(:,thetai);  
             sV = sV' ; 
             sV = repmat(sV,1,1,obj.nfft/2+1);
             sV = permute(sV,[3 2 1]); 
             s_out(:,thetai) =sum(sV.*s,2); 
          end
       end
       %% MUSIC Algorithm, test
       function s_out = MUSIC(obj,txi,cyclei) 
           index_r = obj.detectRange(cyclei);
           s = obj.signalData(:,txi,:,cyclei);
           s = squeeze(s);
           s = fft(s,obj.nfft,1)./size(s,1);
           for signali = 1:obj.nfft/2+1
               s2 = transpose(s(signali,:,:));
               s2 = corrcoef(s2*s2');
               [V,D] = eig(s2);
               [D I] = sort(diag(D),'descend');
               V = V(:,I);
               U_n = V(:,2:end);
               for thetai = 1:obj.ntheta
                   sV = obj.steeringVector(:,thetai);
                   a = sV'*U_n*U_n'*sV;
                   s_out(signali,thetai) = sV'*sV/a;
               end
           end 
       end
       %% Azimuth Detection 
       function [detections] = detectAzimuth(obj,cyclei)
           index_r = obj.detectRange(cyclei); 
           index_rA = []; 
           s = obj.rangeAzimuth(1,cyclei); 
           counter = 1; 
           for i = 1:size(index_r,1)
               [a,b] = findpeaks(abs(s(index_r(i),:))); 
               detection = a > 0.4; 
               index = find(detection); 
               c = repmat(index_r(i),size(index)); 
               index_rA = [index_rA [c;b(index)]];     
           end 
           if isempty(index_rA) == 0
               detections = [obj.rLin(index_rA(1,:)); obj.thetaLin(index_rA(2,:))];
           else
               detections = [];     
           end
       end 
   end
end