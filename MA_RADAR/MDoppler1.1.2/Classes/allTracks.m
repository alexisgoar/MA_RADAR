% The class allTracks contains all the tracks available in the current
% time, the class also obtains the detections each time step
% Gating and assignment algorithms are performed here. 

classdef allTracks < handle
    properties
        tracks
        counter
        deltaT
    end
    methods
        %Constructor function 
        function obj = allTracks(deltaT) 
            temp(100) = Track(); 
            obj.tracks = temp; 
            obj.counter = 0; 
            obj.deltaT = deltaT; 
            %tracks = Stack(); 
        end 
        % Read detections
        function read(obj,detections) 
            %If no tracks have been started start new tracks with the new
            %detections 
            if obj.counter == 0         
               N = size(detections,2);
               for i = 1:N
                  obj.beginTrack(obj.deltaT,detections(1,i),detections(2,i));  
               end
               % For testing
               obj.tracks(1).X = [detections(1,1);detections(2,1);3;0]; 
               obj.tracks(2).X = [detections(1,2);detections(2,2);0;5]; 
            else
  
                % Testing
                %for j = 1:obj.counter
                %    obj.tracks(j).kalmanF(detections);
                %end
                %Here call for gating function
                % Gating returns a matrix of 1 and 0 depending on wheter or
                % not the gate of track i contains measurement j
                M = obj.gating(detections);
                
                % Testing
                for i = 1:obj.counter
                    for j = 1:size(detections,2)
                        if M(i,j) == 1
                           obj.tracks(i).kalmanF(detections(:,j));
                        end
                    end
                end
                
                % Distance function determination 
                M = obj.NDF(detections,M);
                % Solve the Assignment problem: Different algorithms have
                % been implemented to be tested 
                M = suboptimal1(M); 
            end
            
        end 
        % Gating
        function M = gating(obj,detections)
            M = zeros(obj.counter,size(detections,2)); 
            for i = 1:obj.counter 
               for j = 1:size(detections,2)
                   diff_x = abs(obj.tracks(i).x_est - detections(1,j));
                   diff_y = abs(obj.tracks(i).y_est - detections(2,j)); 
                   if (diff_x < obj.tracks(i).Gx) &&...
                           (diff_y < obj.tracks(i).Gy)
                      M(i,j) = 1;  
                   end
               end
            end
        end
        % Normalized Distance Function determination 
        function M = NDF(obj,detections,M)
            for i = 1:obj.counter
                current_track = obj.tracks(i);
                for j = 1:size(detections,2)
                    if M(i,j) == 1
                       
                        res = detections(:,j)-current_track.X(1:2); 
   
                        dij_sq = transpose(res)/current_track.S*res; 
                        % not sure here 
                        M(i,j) = abs(dij_sq + log(det(current_track.S)));
                        
                    end
                end
            end
            
        end
 %-----------------Assignment Problem------------------------------------%
 


 function M = suboptimal2(M)
     
 end
 
 
 
 
 
 %-----------------------------------------------------------------------%
        
        %Create a new Track
        function beginTrack(obj,deltaT,x_est,y_est)
            obj.counter = obj.counter + 1;
            temp = Track(deltaT,x_est,y_est); 
            obj.tracks(obj.counter) = temp; 
        end 
    end
end