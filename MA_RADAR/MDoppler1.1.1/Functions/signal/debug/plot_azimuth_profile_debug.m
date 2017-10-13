function [s_new,s_old] = plot_azimuth_profile_debug(obj,NPulses)
txn = obj.tx.numberofElements;
rxn = obj.rx.numberofElements;
targetn = size(obj.target,2);  


temp = 0; 
theta =   [-90:1:90]*pi/180;
for thetai = 1:size(theta,2)
    time_signal_out = zeros(txn,rxn,54*(NPulses-1)); 
    freq_signal_out = zeros(txn,rxn,54*(NPulses-1));
    for txi = 1:txn
        for rxi = 1:rxn
            i = 1; 
            % Get the time domain signal for all targets
           
            while obj.tx.chirpi < NPulses
                for j = 1:size(obj.target,2)
                    s(i,j) =(rxSignal2(obj,obj.tx.time,txi,rxi,j));
                    time_signal_out(txi,rxi,i) = time_signal_out(txi,rxi,i)  + (rxSignal2(obj,obj.tx.time,txi,rxi,j));
                end
                temp = 0;
                timeStamp(i) = obj.tx.time;
                obj.tx.nextStep_sampling();
                i = i+1;
            end
            obj.tx.resetTime(); 
            s_time = sum(s,2);
            s_old = s_time; 
           
            %size(s_time) 
            s_new = time_signal_out(txi,rxi,:);
            s_time = reshape(s_new,54*(NPulses-1),1); 
            freq_signal_out(txi,rxi,:) = fft(s_new); 
            
            
            N=size(timeStamp,2);
            freq =0:1/(obj.tx.samplingRate*N):(N-1)/(N*obj.tx.samplingRate);
            R = obj.tx.c*freq/(obj.tx.k*2);
            
            % FFT to get spectrum
                        
            s_freq = fft(s_time);
            s_freq = freq_signal_out(txi,rxi,:);
            

            
            %Get Steering Vecs
            s_vec = obj.steeringVector(theta(thetai),txi,rxi); 
            
            out(thetai,:,txi,rxi) = s_vec*s_freq; 
            
                    
        end
    end
end
freq_signal_out = fft(time_signal_out,[],3); 

s_new = freq_signal_out; 

profile = sum(out,3); 
profile = sum(profile,4);


figure; 

[R_plot,theta_plot] = meshgrid(R,theta); 
h = surf(R_plot.*sin(theta_plot),R_plot.*cos(theta_plot),abs(profile)); 
set(h,'edgecolor','none');
view(0, 90);


end 