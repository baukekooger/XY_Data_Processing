function [obj] = pick_experiment(obj)

info = h5info(obj.fname);
experiments = {info.Groups.Name}; 
experiments = erase(experiments, '/'); 
obj.experiments = experiments;

uipick = picker; 
uipick.ListBox.Items = experiments; 

while isempty(uipick.Experiment) 
    pause(0.1)
end

experimentname = uipick.Experiment;
if contains(experimentname, 'transmission')
    obj.experiment = 'transmission';
elseif contains(experimentname, 'excitation_emission')
    obj.experiment = 'excitation_emission'; 
elseif contains(experimentname, 'decay')
    obj.experiment = 'decay'; 
end
obj.experimentname = experimentname; 

close(uipick.UIFigure)
clear uipick    
    
end
