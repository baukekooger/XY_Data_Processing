function [experiment] = pick_experiment(items)

uipick = picker; 
uipick.ListBox.Items = items; 

while isempty(uipick.Experiment) 
    pause(0.1)
end

experimentname = uipick.Experiment;
if contains(experimentname, 'transmission')
    experiment = 'transmission';
elseif contains(experimentname, 'excitation_emission')
    experiment = 'excitation_emission'; 
elseif contains(experimentname, 'decay')
    experiment = 'decay'; 
end

close(uipick.UIFigure)
clear uipick    
    
end
