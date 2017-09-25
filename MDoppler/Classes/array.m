classdef array < handle
    properties 
        numerofElements
        spacingofElements
        x
        y
        z
    end
       
    properties (Constant)
        frequency = 72;
        c = 299792458;
    end
    properties (Dependent) 
        lambda; 
    end
    
    methods
        function lambda  = get.lambda(obj)
            lambda = obj.c/obj.frequency;
        end
    end
end