classdef array < handle
    properties 
        numberofElements
        x
        y
        z
        lambda
        spacingofElements
        %Arrays containing location of each individual element
        xE
        yE
        zE
    end
    properties (Constant)
        frequency = 9.25e9;
        c = 299792458;
        %For now only arrays directed in x are enabled
        %To enable other directions complete the get functions of
        %xE, yE, zE 
        direction = [1,0,0]; 
    end
    methods
        function obj = array(numberofElements,x,y,z) 
            if nargin == 1
                obj.numberofElements = numberofElements;
                obj.x = 0; 
                obj.y = 0; 
                obj.z = 0; 
            elseif nargin == 4
                obj.numberofElements = numberofElements;
                obj.x = x; 
                obj.y = y;
                obj.z = z;
            else
                error('Incorrect Number of Inputs');
            end
            
            obj.lambda = obj.c/obj.frequency;
            obj.spacingofElements = obj.lambda/2;
            
            obj.xE = zeros(obj.numberofElements,1);
            for i = 1:obj.numberofElements
                obj.xE(i) = i*obj.spacingofElements+obj.x;
            end
            obj.xE = obj.xE - (obj.numberofElements*obj.spacingofElements+...
                obj.spacingofElements)/2;
            
            obj.yE = obj.y*ones(obj.numberofElements,1);
            
            obj.zE = obj.z*ones(obj.numberofElements,1);
                        
        end
    end
end