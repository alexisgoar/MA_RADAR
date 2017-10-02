% Plots the whole setup given a signal class
% the obj variable must of type signal (class)
function plot_setup(obj)
figure;
set(0,'DefaultFigureWindowStyle','docked');
hold on;
plot(obj.tx);
plot(obj.rx);
size(obj.target,2);
for i  = 1:size(obj.target,2)
    plot(obj.target(i));
end
end