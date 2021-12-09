function read_optifit_data(obj)
% Read the optifit output data and fitparameters and store them in the
% object. 
% Note, the optifit filenames must not be altered. 
    
    % select the file
    fname = uigetfile('*.dat', ['select optifit datafile - ' ...
    'fitparam file should be in same folder']);

    data = importdata(fname); 
    xpoint = extractBetween(fname, '_x', '_y'); 
    ypoint = extractBetween(fname, '_y', '_Data');
    fitdate = extractBetween(fname, 'transmission_', '_x'); 
    
    obj.fitdata.optifit_data.xpoint = str2double(xpoint); 
    obj.fitdata.optifit_data.ypoint = str2double(ypoint); 
    obj.fitdata.optifit_data.fitdate = string(fitdate); 
    
    obj.fitdata.optifit_data.wavelengths = data.data(:,1); 
    obj.fitdata.optifit_data.transmission_experimental = data.data(:,2); 
    obj.fitdata.optifit_data.transmission_fit = data.data(:,3); 
    obj.fitdata.optifit_data.refractive_index = data.data(:,4); 
    obj.fitdata.optifit_data.extinction_coefficient = data.data(:,5); 
    
    fname_params = erase(fname, 'Data.dat'); 
    fname_params = [fname_params, 'FitParam.txt']; 
    fitparams = importdata(fname_params); 
    
    fitparams.data = cellstr(string(fitparams.data)); 
    fitparams.textdata = [fitparams.textdata, fitparams.data]; 
    
    % Make valid names from the imported names. 
    names = matlab.lang.makeValidName(fitparams.textdata(:,1)); 
    obj.fitdata.optifit_data.fitparams = ...
        cell2struct(fitparams.textdata(:,2), names); 

end

