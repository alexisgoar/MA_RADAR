function [index_rA] = detectAzimuth(rSpec,aSpec)
index_r = detectRange(rSpec);
index_rA = [];
s = aSpec;
counter = 1;
for i = 1:size(index_r,1)
    [a,b] = findpeaks(abs(s(index_r(i),:)));
    detection = a > 0.2;
    index = find(detection);
    c = repmat(index_r(i),size(index));
    index_rA = [index_rA [c;b(index)]];
end
