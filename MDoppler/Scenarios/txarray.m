classdef txarray < array
    properties (Constant)
        tchirp = 135e-6; %s chirp duration
        B = 100e6; %Hz chirp sweeping bandwith 
        samplingRate = 2.5e-6; 
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
        end
        function k = get.k(obj)
            k = obj.B/obj.tchirp; 
        end
        
        function plot(obj)
            plot(obj.xE,obj.yE,'k*');
        end
    end
end