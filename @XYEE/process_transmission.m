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
xnum = h5readatt(obj.fname, '/', 'xnum');
ynum = h5readatt(obj.fname, '/', 'ynum');
finfo = ncinfo(obj.fname);
dimnames = {finfo.Dimensions.Name};
dimsizes = [finfo.Dimensions.Length];
em_sz = dimsizes(strcmp('emission_wavelengths', dimnames));
obj.em_wl = unique(h5read(obj.fname, '/x000y000/emission'));

% deuterium_peak = ((obj.em_wl>654) & (obj.em_wl<659));

obj.spectrum = NaN(xnum, ynum, em_sz);
obj.xycoords = NaN(xnum, ynum, 2);

%% Read in all the data
for x=1:xnum
    for y=1:ynum
        group = sprintf('/x%03dy%03d/',x-1,y-1);
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

S = reshape(sum(obj.spectrum,3), [xnum ynum]);
if (autocorrect || remove_dark)
    % Remove Dark
    [~, ind] = fullmin(S);
    [subx, suby] = ind2sub(size(S), ind);
    obj.dark = repmat(obj.spectrum(subx, suby, :), ...
        [xnum ynum 1]);
    obj.spectrum = obj.spectrum - obj.dark;
end
if autocorrect
    % Divide by light
    % Light is defined coming from the first row/column of measurements
    if sum(squeeze(obj.spectrum(:, 1, :))) > sum(squeeze(obj.spectrum(1, :, :)))
        obj.spectrum = obj.spectrum ./ ...
                repmat(obj.spectrum(:, 1, :), [1 ynum 1]);
    else
        obj.spectrum = obj.spectrum ./ ...
                repmat(obj.spectrum(1, :, :), [xnum 1 1]);
    end
end

end

