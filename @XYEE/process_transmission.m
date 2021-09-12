function [ obj ] = process_transmission( obj, varargin )
%PROCESS_DECAY Processes XYEE transmission data
%   Returns: an XYEE object

%% Process varargin
varargin = cellflat(varargin);
autocorrect = false;
remove_dark = false;
for k=1:2:numel(varargin)
    switch varargin{k}
        case {'autocorrect', 'ac', 't'}
            autocorrect = varargin{k+1};
        case {'remove_dark', 'rd', 'h'}
            remove_dark = varargin{k+1};
    end
end

%% Turn off specific warnings
warning('off', 'curvefit:prepareFittingData:removingNaNAndInf');

%% Set required variables
xnum = h5readatt(obj.fname, '/transmission/settings/xystage', 'xnum');
ynum = h5readatt(obj.fname, '/transmission/settings/xystage', 'ynum');
finfo = ncinfo(obj.fname);
dimnames = {finfo.Groups.Dimensions.Name};
dimsizes = [finfo.Groups.Dimensions.Length];
em_sz = dimsizes(strcmp('emission_wavelengths', dimnames));
obj.em_wl = unique(h5read(obj.fname, '/transmission/dark/emission'));

% deuterium_peak = ((obj.em_wl>654) & (obj.em_wl<659));

obj.spectrum = NaN(xnum, ynum, em_sz);
obj.xycoords = NaN(xnum, ynum, 2);

%% Read in all the data

obj.dark = h5read(obj.fname, '/transmission/dark/spectrum'); 
obj.lamp = h5read(obj.fname, '/transmission/lamp/spectrum')-obj.dark; 

for x=1:xnum
    for y=1:ynum
        group = sprintf([obj.experimentname '/x%dy%d/',x,y]);
        try
            transmission = h5read(obj.fname, [group 'spectrum'])';
        catch
            transmission = nan(size(obj.em_wl));
        end
        
        % Remove Deuterium peak
%         obj.spectrum(x,y,:) = transmission(~deuterium_peak);
        obj.spectrum(x,y,:) = transmission;
        try
            obj.xycoords(x,y,:) = h5read(obj.fname, [group 'position']);
        catch
        end
    end
end
% obj.em_wl = obj.em_wl(~deuterium_peak);
%% Turn all warnings back on
warning('on', 'curvefit:prepareFittingData:removingNaNAndInf');

if (autocorrect || remove_dark)
    for ii = 1:xnum
        for jj = 1:ynum
            obj.spectrum(ii,jj,:) = squeeze(obj.spectrum(ii,jj,:)) - obj.dark; 
        end
    end
end
if autocorrect
    for ii = 1:xnum
        for jj = 1:ynum
            obj.spectrum(ii,jj,:) = squeeze(obj.spectrum(ii,jj,:)) ./ obj.lamp; 
        end
    end

end
end

