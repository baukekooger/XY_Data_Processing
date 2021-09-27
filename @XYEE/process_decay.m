function [ obj ] = process_decay( obj, varargin )
%PROCESS_DECAY Processes XYEE decay data
%   Returns: an XYEE object

% varargin = cellflat(varargin);
% for ii=1:2:numel(varargin)
%     switch varargin{ii}
%         case 'decay_time'
%             decay_time = varargin{ii+1};
%     end
% end
% disp(['processing decay time with ' decay_time]);

%% Turn off specific warnings
warning('off', 'curvefit:prepareFittingData:removingNaNAndInf');

%% Set required variables
finfo = h5info(obj.fname);
dimnames = {finfo.Datasets.Name};
dimsizes = cellfun(@(x)(x.Size),{finfo.Datasets.Dataspace});
excitation_wavelengths = dimsizes(strcmp('excitation_wavelengths', dimnames));
number_of_pulses = dimsizes(strcmp('number_of_pulses', dimnames));
samples = dimsizes(strcmp('samples', dimnames));
active_channels = dimsizes(strcmp('active_channels', dimnames));

obj.digitizer.spectra = NaN(obj.xystage.xnum, obj.xystage.ynum, ...
    excitation_wavelengths, active_channels, number_of_pulses, samples);
obj.xystage.coordinates = NaN(obj.xystage.xnum, obj.xystage.ynum, 2);

samples = double(obj.digitizer.samples);
sample_rate = double(obj.digitizer.sample_rate);

obj.digitizer.time = linspace(0, samples / sample_rate, samples);
obj.laser.excitation_wavelengths = h5read(obj.fname, '/x1y1/excitation'); 

%% Read in all the data and subtract the noise floor
disp('Automatically correcting decay. If something looks off, edit XYEE.process_decay.');

for x=1:obj.xystage.xnum
    for y=1:obj.xystage.ynum
        group = sprintf('/x%dy%d/', x, y);
        decay = h5read(obj.fname, [group 'pulses']);
        decay = permute(decay, [4 3 2 1]);
        
        decay = -decay; 
        
        % number of values to average over before start of pulse defined by
        % number of samples
        index = max(samples/20, 20); 
        
        meandecay = mean(decay(:,:,:,1:index), 4);
        decay = decay-meandecay; 

        obj.digitizer.spectra(x,y,:,:,:,:) = decay;
        obj.xystage.coordinates(x,y,:) = h5read(obj.fname, [group 'position']);
        
    end
end

%% Normalize and average data if requested in the arguments (default = yes) 

% % normalizing decay curves 
%         decay = decay./max(decay); 

%% Turn all warnings back on
warning('on', 'curvefit:prepareFittingData:removingNaNAndInf');

end

