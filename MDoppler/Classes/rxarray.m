classdef rxarray < array
    properties 
        test
    end
    methods
        function obj = rxarray(numberofElements,x,y,z)
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
        function h = plot(obj)
            h = plot(obj.xE,obj.yE,'r*');
        end
    end
end