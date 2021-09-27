function [ obj ] = rgb_decay_process( obj )
    % RGB_DECAY_PROCESS translates an XYEE decay dataset to RGB coordinates
    %
    %   Author:             Evert PJ Merkx
    %   Contact:            e.p.j.merkx@tudelft.nl
    %   Last revision:      January 3rd 2018
    %   Original version:   December 12th 2017
    
    spectrum = obj.XYEEobj.digitizer.spectra; % (x, y, ex, em, t)
    
    sz = size(spectrum);
    tau = zeros(sz(1:end-1));
    
    for x=1:size(spectrum,1)
        for y=1:size(spectrum,2)
            for ex_wl=1:size(spectrum,3)
                for em_wl=1:size(spectrum,4)
                    dc = squeeze(spectrum(x,y,ex_wl, em_wl,:))';
                    if(sum(isnan(dc)))
                        tau(x,y,ex_wl,em_wl) = 0;
                        fprintf('NaN encountered at (%d, %d, %d, %d)\n',...
                            x, y, ex_wl, em_wl);
                        continue;
                    end
                    sz_dc = size(dc);
                    trig = min([find(dc>0.8,1), sz_dc(end)-10]);
                    % Ignore the laser reflection (first 8 channels (16
                    % ns))
                    % Added min(...,sz_dc(end)) to avoid empty-matrix errors
                    
                    tmax = min([find(smooth(dc(trig+8:end),10)<=0,1) + trig + 8, ...
                        sz_dc(end)]);
                    %T = (trig+8):tmax;
                    % time of interest (time after trigger pulse)
                    T = trig:tmax;
                    decaytime = squeeze(obj.XYEEobj.time(x,y,T));
                    tau(x,y,ex_wl,em_wl) = trapz(decaytime,...
                        decaytime' .* dc(T));
                    tau(x,y,ex_wl,em_wl) = tau(x,y,ex_wl,em_wl) ./ ...
                        trapz(decaytime, dc(T));
                end
            end
        end
    end
    sz_tau = size(tau);
    if numel(size(tau))<3
        sz_tau = [size(tau) 1 1];
    end
    sz_tau = sz_tau.*[1 1 0 0] + [0 0 numel(tau(1,1,:,:)) 0];
    sz_tau = sz_tau(sz_tau>0);
    tau = reshape(tau, sz_tau); % Probably goes wrong with more than 1 ex and 1 em.
    tau_with_mean = zeros(padarray(size(tau)', 3 - length(size(tau)), 1, 'post')' + [0 0 1]);
    tau_with_mean(:,:,1) = max(max(tau,[],4),[],3);
    tau_with_mean(:,:,2:end) = tau;
    obj.rgb = tau_with_mean;
    
end