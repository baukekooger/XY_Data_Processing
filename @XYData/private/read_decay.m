function read_decay(obj)
% note - for plotting of the colors, y is vertical which corresponds to 
% rows. Therefore, the first position parameter is y and not x. 

%% Set required variables
% read the size of the variable dimensions. 
finfo = h5info(obj.fname);
dimnames = {finfo.Datasets.Name};
dimsizes = cellfun(@(x)(x.Size),{finfo.Datasets.Dataspace});
excitation_wavelengths = dimsizes(strcmp('excitation_wavelengths', ...
    dimnames));
samples = dimsizes(strcmp('samples', dimnames));

obj.digitizer.spectra = NaN(obj.xystage.ynum, obj.xystage.xnum, ...
    excitation_wavelengths, samples);
obj.xystage.coordinates = NaN(obj.xystage.ynum, obj.xystage.xnum, 2);

samples = double(obj.digitizer.samples);
sample_rate = double(obj.digitizer.sample_rate);

obj.digitizer.time = 0:(1/sample_rate):((samples-1)/sample_rate);
% round values to a nanosecond to prevent indexing issues due to numerical
% rounding errors. 
obj.digitizer.time = round(obj.digitizer.time, 9); 
obj.laser.excitation_wavelengths = h5read(obj.fname, '/x1y1/excitation'); 

%% Read in all the data 
ynum = obj.xystage.ynum; 
xnum = obj.xystage.xnum; 
for y=1:ynum
    for x=1:xnum
        group = sprintf('/x%dy%d/', x, y);
        decay = h5read(obj.fname, [group 'pulses']);
        decay = permute(decay, [2 1]);
       
        obj.digitizer.spectra(y,x,:,:) = decay;
        obj.xystage.coordinates(y,x,:) = h5read(obj.fname, ...
            [group 'position']);
        % round coordinates to 0.1 mm to prevent any issued due to minorly
        % changing coordinates 
        obj.xystage.coordinates = round(obj.xystage.coordinates, 1); 
    end
end

end

