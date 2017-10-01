classdef discreteSystem < handle
    properties 
        time; 
        t_current_chirp; 
    end
    properties (Constant)
        t0 = 0; 
        timestep = 0.001; 
    end
    properties (Access = private)
        
    end
    properties (Dependent)
        
    end
    methods
        function obj = discreteSystem(~)
            obj.time = obj.t0; 
        end
        function obj = timeStep(obj)
            obj.time = obj.time + obj.timestep;
        end
    end
end

