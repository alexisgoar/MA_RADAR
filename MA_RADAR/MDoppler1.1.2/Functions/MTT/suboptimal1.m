 function M = suboptimal1(M) 
     %Page 95 of Book: Multiple Target Tracking with Radar Applications
     n = size(M,1);
     m = size(M,2);
     M_logic = logical(M);
     execute = 1; 
     

while execute
     M_logic_compare = M_logic; 
     % 1. singly validated tracks
     sM_logic = sum(M_logic,2);
     counter = 1; 
     flag1 = 0; flag2 = 0; flag3 = 0; flag4 = 0; 
     for i = 1:n
         if sM_logic(i) == 1    
             j = find(M_logic(i,:));
             index_One(:,counter) = sub2ind([n m],i,j);
             index_Zero(counter) = j; 
             counter = counter + 1; 
             flag = 1; 
         end
     end
     if flag1
         M_logic(:,index_Zero) = 0 ;
         M_logic(index_One) = 1;
     end
     % 2. singly validated observations
     sM_logic = sum(M_logic,1);
     counter = 1; 
     for j = 1:m 
         if sM_logic(j) == 1
             i = find(M_logic(:,j)); 
             index_One2(:,counter) = sub2ind([n m],i,j);
             index_Zero2(counter) = i; 
             counter = counter + 1; 
             flag2 = 1; 
         end
     end
     if flag2
         M_logic(index_Zero2,:) = 0 ;
         M_logic(index_One2) = 1;
     end
     M = M_logic.*M; 
     execute = sum(sum(M_logic_compare ~= M_logic));
     % 3. and 4
end

% Doesn Work from here: CORRECT!!!
     %5
     sM_logic = sum(M_logic,2);
     counter = 1; 
     for i = 1:n 
        if sM_logic(i) > 1 
           [~,j]= min(M_logic(i,:)); 
           index_One3(:,counter) = sub2ind([n m],i,j); 
           index_Zero3(counter) = i; 
           counter = counter+1; 
           flag3 = 1; 
        end
     end
     if flag3
         M_logic(index_Zero3,:) = 0 ;
         M_logic(index_One3) = 1;
     end
     %6
     sM_logic = sum(M_logic,1);
     counter = 1; 
     for j = 1:m 
        if sM_logic(j) > 1 
           [~,i] = min(M_logic(:,j)); 
           index_One4(:,counter) = sub2ind([n m],i,j);
           index_Zero4(counter) = j; 
           counter = counter+1; 
           flag4 = 1; 
           i 
           j
        end
     end
     if flag4
         M_logic(:,index_Zero4) = 0 ;
         M_logic(index_One4) = 1;
     end
     M_logic
     M = M_logic.*M;
 end