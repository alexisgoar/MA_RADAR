function plot_azimuth_profile(obj,NPulses)
txn = obj.tx.numberofElements;
rxn = obj.rx.numberofElements;

theta =   [-60:1:60]*pi/180;
for thetai = 1:size(theta,2)
    for txi = 1:txn
        for rxi = 1:rxn
            i = 1; 
            % Get the time domain signal for all targets
            while obj.tx.chirpi < NPulses
                for j = 1:size(obj.target,2)
                    s(i,j) =(rxSignal2(obj,obj.tx.time,txi,rxi,j));
                end
                timeStamp(i) = obj.tx.time;
                obj.tx.nextStep_sampling();
                i = i+1;
            end
            obj.tx.resetTime(); 
            s_time = sum(s,2);
            
            N=size(timeStamp,2);
            freq =0:1/(obj.tx.samplingRate*N):(N-1)/(N*obj.tx.samplingRate);
            R = obj.tx.c*freq/(obj.tx.k*2);
            
            % FFT to get spectrum
                        
            s_freq = fft(s_time);
            

            
            %Get Steering Vecs
            s_vec = obj.steeringVector(theta(thetai),txi,rxi); 
            
            out(thetai,:,txi,rxi) = s_vec*s_freq; 
            
                    
        end
    end
end

profile = sum(out,3); 
profile = sum(profile,4);




[R_plot,theta_plot] = meshgrid(R,theta); 
h = surf(R_plot.*sin(theta_plot),R_plot.*cos(theta_plot),abs(profile)); 
set(h,'edgecolor','none');


end 