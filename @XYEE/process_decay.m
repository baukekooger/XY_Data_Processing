function [ obj ] = process_decay( obj, varargin )
%PROCESS_DECAY Processes XYEE decay data
%   Returns: an XYEE object

varargin = cellflat(varargin);
decay_time = '2ns';
for ii=1:2:numel(varargin)
    switch varargin{ii}
        case 'decay_time'
            decay_time = varargin{ii+1};
    end
end
disp(['processing decay time with ' decay_time]);

%% Turn off specific warnings
warning('off', 'curvefit:prepareFittingData:removingNaNAndInf');

%% Set required variables
xnum = h5readatt(obj.fname, '/', 'xnum');
ynum = h5readatt(obj.fname, '/', 'ynum');
finfo = ncinfo(obj.fname);
dimnames = {finfo.Dimensions.Name};
dimsizes = [finfo.Dimensions.Length];
ex_sz = dimsizes(strcmp('excitation_wavelengths', dimnames));
em_sz = dimsizes(strcmp('emission_wavelengths', dimnames));
dg_sz = dimsizes(strcmp('decays', dimnames));

% skip_start = 80;
% skip_end = 20;
obj.spectrum = NaN(xnum, ynum, ex_sz, em_sz, dg_sz);
obj.xycoords = NaN(xnum, ynum, 2);
obj.time = NaN(xnum, ynum, dg_sz);
try
    obj.em_wl = unique(h5read(obj.fname, '/x000y000/emission'));
catch
    % Doesn't matter if this fails
end
obj.ex_wl = unique(h5read(obj.fname, '/x000y000/excitation'));

%% Read in all the data and normalize decay
disp('Automatically correcting decay. If something looks off, edit XYEE.process_decay.');

for x=1:xnum
    for y=1:ynum
        group = sprintf('/x%03dy%03d/',x-1,y-1);
        try
            decay = h5read(obj.fname, [group 'decay'])';
        catch
            fprintf('Major data loss occured at (x,y) = (%d, %d)\n', x, y);
            obj.spectrum(x,y,:,:,:) = nan(size(obj.spectrum(x,y,:,:,:)));
            dxdy = squeeze(obj.xycoords(2,2,:) - obj.xycoords(1,1,:));
            obj.xycoords(x,y,:) = squeeze(obj.xycoords(1,1,:)) + double([x; y]).*dxdy;
            obj.time(x,y,:) = nan(size(obj.time(x,y,:)));
            continue;
        end
%         decay = - decay(:,skip_start:end-skip_end);
        
        d_sz = size(decay);
        d_dim = length(size(decay));
        d_rep = [ones(1,d_dim-1) d_sz(d_dim)];
        
        try
%             decay = decay - repmat(mean(decay(:,1:100),d_dim), d_rep);
%             decay = decay ./ repmat(max(decay(:,100:4000),[],d_dim), d_rep);
            decay = decay - repmat(mean(decay(:,50:200),d_dim), d_rep);
            decay = decay ./ max(decay(100:end-100));
        catch
            fprintf('Processing error occured at (x,y) = (%d, %d)\n', x, y);
            obj.spectrum(x,y,:,:,:) = nan(size(obj.spectrum(x,y,:,:,:)));
            obj.xycoords(x,y,:) = h5read(obj.fname, [group 'position']);
            obj.time(x,y,:) = nan(size(obj.time(x,y,:)));
            continue;
        end         
%         trig = zeros(1,d_sz(1));
%         for ii=1:d_sz(1)
%             trig(ii) = find(decay(ii,:)>0.8,1);
%         end
%         trig = round(median(trig));
%         
%         decay = decay - repmat(mean(decay(:,1:trig-5),d_dim), d_rep);
%         switch decay_time
%             case {'64ns', '64 ns'}
%                 trig = trig+2;
%                 decay = decay ./ repmat(max(decay(:,trig:4000),[],d_dim), d_rep);
%             case {'2ns', '2 ns'}
%                 decay = decay ./ repmat(max(decay(:,trig:4000),[],d_dim), d_rep);
%             case {'2560ns', '2560 ns'}
%                 break;
% %                 continue;
%             otherwise
%                 error('Unknown decay_time in XYEE.process_decay');
%         end
        
        trig = zeros(1,d_sz(1));
        for ii=1:d_sz(1)
            try
                trig(ii) = find(decay(ii,100:end-100)>0.9,1)+100;
            catch
                [trig(ii), ~] = max(decay(ii,100:end-1));
                trig(ii) = trig(ii) + 100;
            end
        end
        trig = round(median(trig));
        obj.spectrum(x,y,:,:,:) = decay;
        obj.xycoords(x,y,:) = h5read(obj.fname, [group 'position']);
        
        switch decay_time
            case {'64ns', '64 ns'}
                % 64 ns time, starting at the trigger point
                obj.time(x,y,:) = (0:64:(64*d_sz(2) - 1)) - 64 * (trig-1);
            case {'2ns', '2 ns'}
                % 2 ns time, starting at the trigger point
                obj.time(x,y,:) = (0:2:(2*d_sz(2) - 1)) - 2 * (trig-1);
            case {'2560ns', '2560 ns'}
                % 2560 ns time, starting at the trigger point
                obj.time(x,y,:) = (0:2560:(2560*d_sz(2) - 1)) - 2560 * (trig);
            otherwise
                error('Unknown decay_time in XYEE.process_decay');
        end

    end
    fprintf('%.2f %% complete!\n', double(x)/double(xnum)*100);
end

%% Turn all warnings back on
warning('on', 'curvefit:prepareFittingData:removingNaNAndInf');

end

