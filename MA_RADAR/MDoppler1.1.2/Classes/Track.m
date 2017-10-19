% Ths track contains all the information about a single track, including
% the current estimate, the gates, and the kalman filter 

classdef Track < handle
    properties
        %Current Position Estimate
        x_est
        y_est
        % Kalman Filer Variables
        P
        deltaT
        A
        X
        Q
        % Gating 
        Gx
        Gy
        % Assignment
        S; 
    end
    properties (Constant) 
       % Kalman Filter COnstants
       R = [1^2,0;0,1^2]; 
       H = [1,0,0,0;0,1,0,0]; 
    end
    methods
        function obj = Track(deltaT,x,y)
            if nargin >2
                obj.x_est = x;
                obj.y_est = y;
                obj.X = [x;y;3;0];
                obj.deltaT = deltaT;
                % Kalman Filter
                obj.P = [1,0,0,0;0,1,0,0;0,0,0,0;0,0,0,0];
                obj.A = [1 0 deltaT 0
                    0 1 0 deltaT
                    0 0 1 0
                    0 0 0 1];
                obj.Q = [0,0,0,0;0,0,0,0;0,0,0,0;0,0,0,0];
                %Gates
                obj.Gx = 3*sqrt(obj.P(1,1)+obj.R(1,1)); 
                obj.Gy = 3*sqrt(obj.P(2,2)+obj.R(2,2)); 
                %Asignment
                obj.S = obj.H*obj.P*transpose(obj.H)+obj.R; 
            end   
        end
        %Kalman
        function kalmanF(obj,zk)
            % extract
            z = [zk(1); zk(2)]; 
            %State Prediction 
            obj.X= obj.A*obj.X; 
            % Error Covariance Prediction
            obj.P = obj.A*obj.P*transpose(obj.A)+obj.Q; 
            %Kalman Gain
            K = obj.P*transpose(obj.H)/(obj.H*obj.P*transpose(obj.H)+obj.R); 
            %New Estimates
            obj.X = obj.X + K*(z- obj.H*obj.X); 
            %Error Covariance
            obj.P = obj.P -K*obj.H*obj.P;         
            % copy to other variables
            obj.x_est = obj.X(1); 
            obj.y_est = obj.X(2); 
            %Update Gates
            obj.Gx = 3*sqrt(obj.P(1,1)+obj.R(1,1));
            obj.Gy = 3*sqrt(obj.P(2,2)+obj.R(2,2));
            %Update residual covariance matrix
            obj.S = obj.H*obj.P*transpose(obj.H)+obj.R;
        end
    end
end