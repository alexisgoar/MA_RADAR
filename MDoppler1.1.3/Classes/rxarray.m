classdef rxarray < array
    properties 
    end
    methods
        function obj = rxarray(numberofElements,x,y,z)
            if nargin == 1
                args{1} =numberofElements;
                %element spacing
                args{2} = 0.5; 
            elseif nargin == 4
                args{1} =numberofElements;
                %element spacing
                args{2} = 0.5; 
                args{3} =x;
                args{4} =y;
                args{5} =z;
            else
                error('Incorrect number of inputs');
            end
            obj@array(args{:});
        end
        function h =  plot(obj,ax)
            if nargin == 1
                h = plot(obj.xE,obj.yE,'b*');
            else
                h = plot(ax,obj.xE,obj.yE,'b*');
            end
        end
    end
end