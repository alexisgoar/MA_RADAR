% Array class to define tx or rx elements
% This class only supports arrays oriented in the x-direction 
% Further properties exclusive for tx or rx are defined in tx.m and rx.m
% tx and rx are subclasses of the array clas 

classdef array < handle
    properties 
        numberofElements
        x
        y
        z
        lambda
        spacingofElements
        %Arrays containing location of each individual element
        %Elements are separated in the x direction by lambda/2
        xE
        yE
        zE
    end
    properties (Constant)
        frequency = 9.25e9;
        c = 299792458;
    end
    methods
        function obj = array(numberofElements,spacing,x,y,z)         
            % Init 
            obj.lambda = obj.c/obj.frequency;
            if nargin == 2
                obj.numberofElements = numberofElements;
                obj.x = 0; 
                obj.y = 0; 
                obj.z = 0; 
                obj.spacingofElements = spacing*obj.lambda;
                
            elseif nargin == 5
                obj.numberofElements = numberofElements;
                obj.x = x; 
                obj.y = y;
                obj.z = z;
                obj.spacingofElements = spacing*obj.lambda;
               
            else
                error('Incorrect Number of Inputs');
            end
            
           

            
            % Calculation of individual element positions 
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