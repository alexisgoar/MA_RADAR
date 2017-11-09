function [index] = detectRange(rSpec)
[a,b] = findpeaks(abs(rSpec(:,1,1)));
detection = a> 0.10;
index = b(detection);
end