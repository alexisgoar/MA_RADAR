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
            %If no tracks have been started and nothing has been detected
            %don't do anything
            if isempty(detections) == 1  && obj.counter == 0
            end
            
            %If no tracks have been started start new tracks with the new
            %detections
            if obj.counter == 0
                N = size(detections,2);
                for i = 1:N
                    obj.beginTrack(obj.deltaT,detections(1,i),detections(2,i));
                end
                % For testing
                %obj.tracks(1).X = [detections(1,1);detections(2,1);0;5];
                %obj.tracks(2).X = [detections(1,2);detections(2,2);0;5];
                %obj.tracks(2).X = [detections(1,3);detections(2,3);2;2];
                %If no detections have been made, but there are existing tracks
                %update tracks with previous estimate
            elseif isempty(detections) == 1
                for i = 1:obj.counter
                    obj.tracks(i).noDetection();
                end
                %Assign detections to corresponding tracks
            else
                % Gating returns a matrix of 1 and 0 depending on wheter or
                % not the gate of track i contains measurement j
                M = obj.gating(detections);
                % Distance function determination
                M = obj.NDF(detections,M);
                % Solve the Assignment problem: Different algorithms have
                % been implemented to be tested
                M_logic = suboptimal1(M);
                % Perform next step of Kalman Filter with the assigned
                % detections
                for i = 1:obj.counter
                    for j = 1:size(detections,2)
                        if M_logic(i,j) == 1
                            obj.tracks(i).kalmanF(detections(:,j));
                        end
                    end
                end
                % For tracks that haven't been assigned a detection:
                [noDetectI] = find(sum(M_logic,2)==0);
                for i = 1:size(noDetectI,1)
                    obj.tracks(noDetectI(i)).noDetection();
                end
                %For detections that haven't been assigned a track
                [noDetectI] = find(sum(M_logic,1)==0);
                for i = 1:size(noDetectI,2)
                    obj.beginTrack(obj.deltaT, detections(1,noDetectI(i)),detections(2,noDetectI(i)));
                end
                
            end
            %delete tracks that have to be deleted
            i = 1;
            while i < obj.counter+1
                to_delete  = obj.tracks(i);
                %track confirmation (initial)
                if to_delete.Np == 6
                    if to_delete.Nm >3
                        to_delete.deleteTentative();
                    else
                        disp(['New Track confirmed']);
                    end
                elseif to_delete.Nmc >5
                    to_delete.deleteTrack();
                end
                i = i+1;
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
                        M(i,j) = (dij_sq + log(det(current_track.S)));                        
                    end
                end
            end          
        end 
        %Create a new Track
        function beginTrack(obj,deltaT,x_est,y_est)
            disp(['New tentative track']); 
            obj.counter = obj.counter + 1;
            temp = Track(deltaT,x_est,y_est,obj); 
            obj.tracks(obj.counter) = temp; 
        end 
        %Plotting
        function plotTracks(obj,axes)
           for i = 1:obj.counter
              obj.tracks(i).plotTrack(axes);  
           end
        end
    end
end