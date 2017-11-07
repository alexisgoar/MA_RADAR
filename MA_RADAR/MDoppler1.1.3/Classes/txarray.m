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
                %Element spacing
                args{2} = 4.5; 
            elseif nargin == 4
                args{1} =numberofElements;
                %Element spacing
                args{2} = 4.5; 
                args{3} =x;
                args{4} =y;
                args{5} =z;
            else
                error('Incorrect number of inputs');
            end
            obj@array(args{:});
            obj.k = obj.B/obj.tchirp; 
            obj.samplingRate = obj.tchirp/obj.samplesPerChirp;    
        
        end
        function h =  plot(obj,ax)
            if nargin == 1
                h = plot(obj.xE,obj.yE,'r*');
            else
                h = plot(ax,obj.xE,obj.yE,'r*');
            end
        end 
    end
end