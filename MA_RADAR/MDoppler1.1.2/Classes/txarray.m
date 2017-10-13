classdef txarray < array
    properties
        k; 
        samplingRate; %s (wrongly named) 
    end
    properties (Constant)
        tchirp = 135e-6; %s chirp duration
        B = 100e6; %Hz chirp sweeping bandwith 
        samplesPerChirp = 54; 
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
            obj.k = obj.B/obj.tchirp; 
            obj.samplingRate = obj.tchirp/obj.samplesPerChirp;      
        end
        function h =  plot(obj,ax)
            if nargin == 1
                h = plot(ax,obj.xE,obj.yE,'k*');
            else
                h = plot(ax,obj.xE,obj.yE,'k*');
            end
        end 
    end
end