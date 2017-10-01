classdef txarray < array
    properties
        % Time keeping variables
        time; 
        t_current_chirp; 
        chirpi=1; %counter for chirps
        tx_flags; % for turning each transmitter on and off
        next;   % next transmitter to turn on 
    end
    properties (Constant)
        tchirp = 135e-6; %s chirp duration
        B = 100e6; %Hz chirp sweeping bandwith 
        samplingRate = 2.5e-6; 
        %TIme keeping variables
        t0 = 0 ; 
        gTimeStep =1e-6; %Time step used globally         
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
            obj.tx_flags = zeros(numberofElements,1); 
            obj.tx_flags(1)  = 1; 
            obj.next = 2; 
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
                obj.tx_flags =obj.tx_flags*0; 
                obj.tx_flags(obj.next) = 1; 
                if obj.next == obj.numberofElements
                    obj.next = 1; 
                else
                    obj.next = obj.next+1; 
                end
            end
        end
        
        function resetTime(obj)
            obj.time = obj.t0; 
            obj.t_current_chirp = obj.t0; 
            obj.chirpi = 1; 
            obj.tx_flags =obj.tx_flags*0;
            obj.tx_flags(1) =1;
            obj.next = 2; 
        end
        % Gets frequency of the signal depending on time for trasnmitter txi
        % Chirps not considered in this function
        % this function is only to be used by other functions in this class
        % definition
        function s = txSignal(obj,txi,time)
            s = (obj.frequency + obj.k*(time-obj.tchirp/2+obj.t0))*obj.tx_flags(txi); 
        end
        % Plots frequency of the signal vs time for transmitter txi 
        function h = plot_txSignal(obj,txi,NPulses)
            i = 1;
            while obj.chirpi < NPulses
                freq(i) = txSignal(obj,txi,obj.t_current_chirp); 
                timeStamp(i) = obj.time; 
                obj.nextStep();   
                i = i+1; 
            end
            h = plot(timeStamp,freq); 
        end
        % Plots frequency of the signal vs time for all transmitters
        function h = plot_txSignals(obj,NPulses)
            figure;
            set(0,'DefaultFigureWindowStyle','docked');
            hold on;
            txn = obj.numberofElements; 
            for i = 1:txn
                h = subplot(txn,1,i);
                obj.plot_txSignal(i,NPulses);
                Txnum = ['Tx ',num2str(i)];
                title([Txnum]);
                set(gca,'ylim',[obj.frequency-obj.k*obj.tchirp,...
                    obj.frequency+obj.k*obj.tchirp]);
                set(gca,'xlim',[obj.t0,obj.tchirp*NPulses]); 
                obj.resetTime(); 
            end
        end
    end
end