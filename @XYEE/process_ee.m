function [ obj ] = process_ee( obj )
%PROCESS_EE Processes XYEE excitation/emission data
%   Returns: an XYEE object

%% Turn off specific warnings
warning('off', 'curvefit:prepareFittingData:removingNaNAndInf');

%% Set required variables
xnum = h5readatt(obj.fname, '/', 'xnum');
ynum = h5readatt(obj.fname, '/', 'ynum');
% finfo = ncinfo(obj.fname);
finfo = h5info(obj.fname);
% dimnames = {finfo.Dimensions.Name};
dimnames = {finfo.Datasets.Name};
% dimsizes = [finfo.Dimensions.Length];
dimsizes = cellfun(@(x)(x.Size),{finfo.Datasets.Dataspace});
ex_sz = dimsizes(strcmp('excitation_wavelengths', dimnames));
em_sz = dimsizes(strcmp('emission_wavelengths', dimnames));
pm_sz = dimsizes(strcmp('power', dimnames));

obj.spectrum = NaN(xnum, ynum, ex_sz, em_sz);
obj.dark = NaN(xnum, ynum, ex_sz, em_sz);
obj.power = NaN(xnum, ynum, ex_sz, 1);
obj.xycoords = NaN(xnum, ynum, 2);
em_wl = h5read(obj.fname, '/x000y000/emission');
sm_resp = xlsread('QE65000_Efficiency.xlsx');
obj.ex_wl = h5read(obj.fname, '/x000y000/excitation');

%% Read in all the data and correct power-per-point
% disp('INFO: Correcting for power as 1/(E * wl)');
disp('INFO: Correcting for power as 1/E');
for x=1:xnum
    for y=1:ynum
        try
            group = sprintf('/x%03dy%03d/',x-1,y-1);
            spectrum = h5read(obj.fname, [group 'spectrum']);
            dark = h5read(obj.fname, [group 'dark']);
            spectrum_t = h5read(obj.fname, [group 'spectrum_t']);
            power = h5read(obj.fname, [group 'power_meas']);
            power_t = h5read(obj.fname, [group 'power_t']);
            obj.xycoords(x,y,:) = h5read(obj.fname, [group 'position']);
        catch
            fprintf(...
                'Measurement interrupted before x=%d,y=%d could be reached\n',...
                x, y);
            continue;
        end
        
        % Check if QE65000 is being used
        if (max(em_wl)<1000 && numel(em_wl)<2000)
            obj.spectrum = obj.spectrum(:,:,:,1:size(sm_resp,1));
            spectrum = interp1(em_wl, spectrum, sm_resp(:,1));
            spectrum = spectrum ./ repmat(sm_resp(:,2), 1, length(obj.ex_wl));
        end

        obj.dark(x, y, :, :) = dark';
        
        for ex=1:ex_sz
            try
                p_t = power_t(:,ex);
                p = power(:,ex);
                [T, P] = prepareCurveData(p_t, p);
                P = cumtrapz(T,P);
                P = [P(1); P(2:2:end)];
                T = [T(1); T(2:2:end)];
                % Interpolate the powermeter measurements to match the spectrometer
                % measurements in time and sum over these
                xq = arrayfun(@(a,b) (linspace(a, b, 100)),...
                    spectrum_t(1:2:end, ex), spectrum_t(2:2:end, ex),...
                    'UniformOutput', false);

                if( T(1) - xq{1}(1) <= 0 )
                    sprintf(...
                    'Powermeter started after Spectrometer! (%.3f %.3f) x%.03dy%.03d', ...
                    T(1), xq{1}(1), x-1, y-1 );
                end
                if( T(end) - xq{1}(end) >= 0 )
                    sprintf(...
                    'Powermeter stopped before Spectrometer! (%.3f %.3f) x%.03dy%.03d', ...
                    T(end), xq{1}(end), x-1, y-1 ) ;
                end

                px = cellfun(@(x)(interp1(T,P,x,'linear',0)), xq, 'UniformOutput', false);
                px = sum(cellfun(@(x)(x(end)-x(1)), px));           
                
                obj.spectrum(x,y,ex,:) = spectrum(:,ex) ./ ( px.*1e6 );
                obj.power(x,y,ex,:) = px;
            catch e
                disp(e.message);
                disp('Something went wrong during your measurement...');
            end
        end
        
    end
end
if (max(em_wl)<1000 && numel(em_wl)<2000)
    disp('INFO: Correcting for QE65000 response');
    obj.em_wl = sm_resp(:,1);
else
    obj.em_wl = em_wl;
end

%% Turn all warnings back on
warning('on', 'curvefit:prepareFittingData:removingNaNAndInf');
end

