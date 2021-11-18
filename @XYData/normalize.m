function [ obj ] = normalize( obj, varargin )
%NORMALIZE normalizes XYEE emission scan data
%   Returns: an XYEE object

varargin = cellflat(varargin);

obj.spectrum = squeeze(obj.spectrum);

for ii = 1:2:length(varargin)
    switch varargin{ii}
        case {'energy', 'E'}
            obj = normalize_energy( obj );
            disp('Normalizing energy');
        case {'wavelength', 'wl'}
            obj = normalize_wavelength( obj );
            disp('Normalizing wavelength');
    end
end

    function obj = normalize_energy( obj )
        xy = obj.spectrum;
        wl = obj.em_wl;
        xy = xy .* permute(repmat(wl.^2,[1 size(xy,1) size(xy,2)]), ...
                    [2 3 1]);
        xy = xy./repmat(max(xy(:,:,find(obj.em_wl>350,1):end),[],3),[1 1 size(xy,3)]);
        obj.spectrum = xy;
    end

    function obj = normalize_wavelength( obj )
        xy = obj.spectrum;
        xy = xy ./ repmat(max(xy,[],3),[1 1 size(xy,3)]);
        obj.spectrum = xy;
    end

end

