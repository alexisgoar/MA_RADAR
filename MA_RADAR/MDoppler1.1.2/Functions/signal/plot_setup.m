% Plots the whole setup given a signal class
% the obj variable must of type signal (class)
function  plot_setup(obj,ax)
if nargin == 1
plot(obj.tx);
plot(obj.rx);
size(obj.target,2);
for i  = 1:size(obj.target,2)
    plot(obj.target(i));
end
else 
    plot(obj.tx,ax);
plot(obj.rx,ax);
size(obj.target,2);
for i  = 1:size(obj.target,2)
    plot(obj.target(i),ax);
end
end
end