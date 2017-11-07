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
        S
        %Trackinitiation 
        Np %Steps_performed
        Nm %Steps with no measurement
        Nmc % Consecutive steps with no new info 
        flag %used for track deletion 
        %link to all tracks
        tracker
        id
        % For plotting 
        x_hist 
        y_hist
        i
        color
    end
    properties (Constant) 
       % Kalman Filter COnstants
       R = [2^2,0;0,2^2]; 
       H = [1,0,0,0;0,1,0,0]; 
    end
    methods
        %Constructor 
        function obj = Track(deltaT,x,y,tracker)
            if nargin >2
                obj.x_est = x;
                obj.y_est = y;
                obj.X = [x;y;0;0];
                obj.deltaT = deltaT;
                % Kalman Filter
                R = obj.R;
                obj.P = [R(1,1),R(1,2),R(1,1)/obj.deltaT,R(1,2)/obj.deltaT;
                    R(1,2),R(2,2),R(1,2)/obj.deltaT,R(2,2)/obj.deltaT;
                    R(1,1)/obj.deltaT,R(1,2)/obj.deltaT,2*R(1,1)/obj.deltaT,2*R(1,2)/obj.deltaT;
                    R(2,1)/obj.deltaT,R(2,2)/obj.deltaT,2*R(2,1)/obj.deltaT,2*R(2,2)/obj.deltaT];

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
                %Tentative Track 
                obj.Np = 0; 
                obj.Nm = 0; 
                obj.Nmc = 0;
                %Track deletion
                obj.flag = 0; 
                %Link to an allTracksClass
                obj.tracker = tracker; 
                obj.id = tracker.counter; 
                %For plotting
                obj.x_hist = zeros(1,500); 
                obj.y_hist = zeros(1,500); 
                obj.x_hist(1) = x; 
                obj.y_hist(1) = y; 
                obj.i = 1; 
                counter = tracker.counter; 
                if mod(counter,5) == 1
                    obj.color = 'red'; 
                elseif mod(counter,5) == 2
                    obj.color = 'blue';
                elseif mod(counter,5) == 3
                    obj.color = 'green'; 
                elseif mod(counter,4) == 4
                    obj.color = 'yellow'; 
                else
                    obj.color = 'black';
                end
            end   
        end
        %Destructor
        function delete(obj)

        end
        function deleteTentative(obj)
            obj.tracker.tracks(obj.id) = [];
            
            for ii = obj.id:obj.tracker.counter
                obj.tracker.tracks(ii).id = obj.tracker.tracks(ii).id-1; 
            end
            obj.tracker.counter = obj.tracker.counter-1;
           disp(['Tentative track discarded']);  
           delete(obj);
        end
        function deleteTrack(obj)

            
            obj.tracker.tracks(obj.id) = [];
            
            for ii = obj.id:obj.tracker.counter
                obj.tracker.tracks(ii).id = obj.tracker.tracks(ii).id-1; 
            end
            obj.tracker.counter = obj.tracker.counter-1;
            disp(['Track deleted after 5 missed detections']);
            
            delete(obj);

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

            
                        %track hisotry
            obj.i = obj.i+1;
            obj.x_hist(obj.i) = obj.x_est;
            obj.y_hist(obj.i) = obj.y_est;
            obj.Np = obj.Np +1 ;

            % track deletion
            if (obj.flag == 0)
                obj.Nmc = 0;
            else
                obj.Nmc = obj.Nmc+1;
                obj.flag = 0;
            end

        end
        
        function noDetection(obj)
           zK = [obj.x_est;obj.y_est];
           obj.Nm = obj.Nm+1; 

           obj.flag = 1; 
           obj.kalmanF(zK); 
        end
        
        function plotTrack(obj,axes) 

           if obj.i > 6
               plot(axes,obj.x_hist(1:obj.i),obj.y_hist(1:obj.i),'o','MarkerSize',5,'MarkerFaceColor',obj.color,'MarkerEdgeColor','none') ; 
           end
        end
    end
end