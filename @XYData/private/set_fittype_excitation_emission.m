function set_fittype_excitation_emission(obj)
% set the fitdata.fittype attribute to the corresponding library 
% curve name.
    number_of_gaussians = obj.datapicker.FitTypeDropDown.Value; 
    obj.fitdata.fittype = ['gauss' number_of_gaussians]; 
    
end