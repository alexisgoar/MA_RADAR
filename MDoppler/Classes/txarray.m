classdef txarray < array
    properties
        % Time keeping variables
        time; 
        t_current_chirp; 
        chirpi=1; %counter for chirps
        gTimeStep =2.5e-6; %Time step used globally      
    end
    properties (Constant)
        tchirp = 135e-6; %s chirp duration
        B = 100e6; %Hz chirp sweeping bandwith 
        samplingRate = (2.5e-6); %s
        %TIme keeping variables
        t0 = 0 ;    
    end
    properties (Dependent) 
        k % Chirp rate 
    end
    methods
        function obj = txarray(numberofElements,x,y,z)
            if nargin == 1
                args{1} =numberofElements;
            elseif nargin == 4
                args{1} =numberofElements;
                args{2} =x;
                args{3} =y;
                args{4} =z;
            else
                error('Incorrect number of inputs');
            end
            obj@array(args{:});
            % Time keeping init
            obj.time = obj.t0;
            obj.t_current_chirp  = obj.t0;
        end
        function k = get.k(obj)
            k = obj.B/obj.tchirp; 
        end
        function h =  plot(obj)
           h = plot(obj.xE,obj.yE,'k*');
        end
        % Updates time values for the next Step
        function nextStep(obj)
            obj.time = obj.time + obj.gTimeStep; 
            obj.t_current_chirp = obj.t_current_chirp + obj.gTimeStep;
            if obj.t_current_chirp > obj.tchirp
                obj.t_current_chirp = 0; 
                obj.chirpi = obj.chirpi+1; 
            end
        end
        function nextStep_sampling(obj)
           obj.time = obj.time + obj.samplingRate;  
           obj.t_current_chirp = obj.t_current_chirp + obj.samplingRate;
           if obj.t_current_chirp > obj.tchirp
               obj.t_current_chirp = 0;
               obj.chirpi = obj.chirpi+1;
           end
        end
        function resetTime(obj)
            obj.time = obj.t0; 
            obj.t_current_chirp = obj.t0; 
            obj.chirpi = 1; 
        end
        % Gets frequency of the signal depending on time for trasnmitter txi
        % Chirps not considered in this function
        % this function is only to be used by other functions in this class
        % definition
        function s = txSignal(obj,txi,time)
            [flag,chirp_id] = obj.tx_flags(time,txi); 
            t_currentchirp = time-(chirp_id-1)*obj.tchirp; 
            if time < obj.t0
                s = 0; 
            else
            s = (obj.frequency + obj.k*(t_currentchirp-obj.tchirp/2+obj.t0))*flag; 
            end
        end
        function [f,chirpid] = tx_flags(obj,time,txi)
            if time < obj.t0 
                f =0; 
                chirpid = 0; 
                return;
            end
           chirpid = floor(time/obj.tchirp)+1;
           n = obj.numberofElements;  
           on_index = mod(chirpid,n); 
           if on_index == 0
               on_index = n;
           else
           end
           if txi == on_index
               f = 1;
           else
               f = 0;
           end   
        end
    end
end