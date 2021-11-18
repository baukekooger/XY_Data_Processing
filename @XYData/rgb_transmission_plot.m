function obj = rgb_transmission_plot(obj)

% Creates an interactive plot with two windows. One window is a datapicker
% app which allows selecting datapoints and types of spectra as well as
% other features. Other window is the plotwindow which shows various graphs


obj.plotwindow = figure();
% Setup the display window
% todo make into function where this can be interactive  
figure(obj.plotwindow);
if(~isempty(obj.fitdata))
    spectrum_plot = subplot(3,4,1:8);
    rgb_plot = subplot(3,4,9);
    thickness_plot = subplot(3,4,10);
    ref_inx_plot = subplot(3,4,11);
    ext_coeff_plot = subplot(3,4,12);
else
    spectrum_plot = subplot(1,5,[1 2 3 4]);
    rgb_plot = subplot(1,5,5);
end

obj.datapicker = picker_transmission;
dcm = datacursormode(obj.datapicker.UIFigure);
dcm.Enable = 'on';
set(dcm, 'UpdateFcn', @updateDisplay);

% init datapicker plottype and connect functions
plottype_init = obj.datapicker.DataDropDown.Value;
obj = set_spectra_plot_transmission(obj, plottype_init);

set(obj.datapicker.DataDropDown, 'ValueChangedFcn', @changespectra)

    function changespectra(~, event)
        % changes the set spectrum and axes, then calls update display to
        % update data. Datapicker selection is not changed.
        obj = set_spectra_plot_transmission(obj, event.Value);
        switch event.Value
            case 'Transmission'
                ylabel(spectrum_plot, 'Transmittance');
                set(spectrum_plot, 'YLim', [0 1]);
                title(spectrum_plot, 'Transmission Spectra');
            case {'Raw Data'}
                ylabel(spectrum_plot, 'Spectrometer Counts');
                set(spectrum_plot, 'YLim', [-inf inf]);
                title(spectrum_plot, 'Unprocessed Spectra');
            case {'Dark Removed'}
                ylabel(spectrum_plot, 'Spectrometer Counts');
                set(spectrum_plot, 'YLim', [-inf inf]);
                title(spectrum_plot, ...
                    'Spectra with Dark Spectrum Removed');
        end
        plotcursorselection
    end

x = uniquetol(obj.xystage.coordinates(:,:,1), 0.005);
y = uniquetol(obj.xystage.coordinates(:,:,2), 0.005);

x = x-min(x); y = y-min(y);

imagesc(rgb_plot, x, y, obj.plotdata.rgb);

if length(x) > 1
    xdiff = (x(2)-x(1))/2;
else
    xdiff = 0;
end
if length(y) > 1
    ydiff = (y(2) - y(1))/2;
else
    ydiff = 0;
end

xlabel(rgb_plot, 'x (mm)');
ylabel(rgb_plot, 'y (mm)');
set(rgb_plot, 'XLim', [x(1)-xdiff x(end)+xdiff]);
set(rgb_plot, 'YLim', [y(1)-ydiff y(end)+ydiff]);
set(rgb_plot, 'XTick', x);
set(rgb_plot, 'YTick', y);
xtickformat(rgb_plot,'%.1f');
ytickformat(rgb_plot,'%.1f');
% not very elegant way to flip the axes ticks (imagesc works annoying with 
% standard flipping) but it doesn't affect any of the data selection.
rgb_plot.YTickLabel = flip(rgb_plot.YTickLabel); 
axis image

% Setup the datapicker window
imagesc(obj.datapicker.UIAxes, obj.plotdata.rgb);
set(obj.datapicker.UIAxes, 'XTick', 1:numel(x));
set(obj.datapicker.UIAxes, 'YTick', 1:numel(y));
set(obj.datapicker.UIAxes, 'XLim', [(1-0.5) (numel(x)+0.5)]);
set(obj.datapicker.UIAxes, 'YLim', [(1-0.5) (numel(y)+0.5)]);
% not very elegant way to flip the axes ticks (imagesc works annoying with 
% standard flipping) but it doesn't affect any of the data selection.
obj.datapicker.UIAxes.YTickLabel = flip(obj.datapicker.UIAxes.YTickLabel); 

% Set non-changing axes values of the spectrum plot
xlabel(spectrum_plot, 'Wavelength (nm)');
set(spectrum_plot, 'XLim', [obj.spectrometer.wavelengths(1) ...
    obj.spectrometer.wavelengths(end)])
% Set initial values of the Y axis 
ylabel(spectrum_plot, 'Transmittance');
set(spectrum_plot, 'YLim', [0 1])

    function flag = isMultipleCall()
        flag = false;
        % Get the stack
        s = dbstack();
        if numel(s)<= 2
            % Stack too short for a multiple call
            return
        end

        % How many calls to the calling function are in the stack?
        names = {s(:).name};
        TF = strcmp(s(2).name,names);
        count = sum(TF);
        if count>1
            % More than 1
            flag = true;
        end
    end

    function text = updateDisplay(~, event_obj)
        if isMultipleCall();  return;  end
        plotcursorselection
        % This is the only part where flipping the Y label ticks bites us,
        % we need to invert the Y value over the range to show correctly in
        % the data picker.
        flipy = flip(1:numel(y)); 
        pos2flip = flipy(event_obj.Position(2)); 
        text = sprintf('X: %.0f\nY: %.0f', event_obj.Position(1), ...
            pos2flip);
    end

    function plotcursorselection()
        ci = dcm.getCursorInfo();
        % Delete all lines in the rgb plot and spectrum plot
        delete(findobj([rgb_plot, spectrum_plot], 'Type', 'Line'))
        hold(spectrum_plot, 'on');
        hold(rgb_plot, 'on');
        for ii=1:length(ci)
            pos = ci(ii).Position;
            plot(spectrum_plot, obj.spectrometer.wavelengths, ...
                squeeze(obj.plotdata.spectra_transmission(pos(2), ...
                pos(1),:)));
            xd = x(pos(1));
            yd = y(pos(2));
            plot(rgb_plot, xd, yd, 'o', 'color', ...
                [spectrum_plot.Children(1).Color 0.8], ...
                'markersize', 5);
            plot(rgb_plot, xd, yd, 'o', 'color', 'k',...
                'markerfacecolor', spectrum_plot.Children(1).Color,...
                'markersize', 5);
        end
        hold(rgb_plot, 'off');
        hold(spectrum_plot, 'off');
    end

    function plotFittedData(x, y, plothandle, index)
        wl = obj.em_wl;
        c = [plothandle.Children(1).Color 0.75];
        m = obj.fitdata.fitresult{x,y};
        m = m(wl);
        cooi = plothandle.ColorOrderIndex;
        if withOffset
            additional = + withOffset*(index-1);
        else
            additional = 0;
        end;
        h= plot(plothandle, wl, m + additional, '--', 'color', c);
        h.DisplayName = '';
        plothandle.ColorOrderIndex = cooi;
    end

% use_nanmat = true;
% withOffset = false;

% try
%     rsq = cellfun(@(x)(x.rsquare),obj.fitdata.gof);
%     d = cellfun(@(x)(x.d),obj.fitdata.fitresult);
%     d = permute(d, [2 1]);
%     rsq = permute(rsq, [2 1]);
%     nanmat = ones(size(rsq));
%     if (use_nanmat); nanmat(rsq<use_nanmat) = nan; end;
%     set(display,'CurrentAxes',thickness_plot);
%     imagesc(x, y, d.*nanmat);
%     hold all;
%     contour(x, y, d.*nanmat,'color','k', 'ShowText', 'on');
%     hold off;
%     xlabel(thickness_plot, 'x (mm)');
%     ylabel(thickness_plot, 'y (mm)');
%     axis equal;
%     set(thickness_plot, 'XLim', [x(1) x(end)]);
%     set(thickness_plot, 'YLim', [y(1) y(end)]);
%
%
%     n = @(a, b, x)( sqrt( 1 + a .* x.^2 ./ (x.^2 - b.^2)) );
%     ref_inxs = cellfun(@(x)(n(x.an, x.bn, 589)), ...
%         obj.fitdata.fitresult);
%     ref_inxs = permute(ref_inxs, [2 1]);
%     set(display,'CurrentAxes',ref_inx_plot);
%     imagesc(x, y, ref_inxs.*nanmat);
%     hold all;
%     contour(x, y, ref_inxs.*nanmat,'color','k', 'ShowText', 'on');
%     hold off;
%     xlabel(ref_inx_plot, 'x (mm)');
%     ylabel(ref_inx_plot, 'y (mm)');
%     axis equal;
%     set(ref_inx_plot, 'XLim', [x(1) x(end)])
%     set(ref_inx_plot, 'YLim', [y(1) y(end)]);
%
%
%     k = @(a, b, c, d, e, x)( 1240*a .* x  .* (1./x - 1./b).^2 .* heaviside(b-x) ...
%         + c + d./x + e./x.^2 );
%     ext_coeffs = cellfun(@(x)(k(x.ak, x.bk, x.ck, x.dk, x.ek, 350)), ...
%         obj.fitdata.fitresult);
%     ext_coeffs = permute(ext_coeffs, [2 1]);
%     set(display,'CurrentAxes',ext_coeff_plot);
%     imagesc(x, y, ext_coeffs.*nanmat);
%     hold all;
%     contour(x, y, ext_coeffs.*nanmat,'color','k', 'ShowText', 'on');
%     hold off;
%     xlabel(ext_coeff_plot, 'x (mm)');
%     ylabel(ext_coeff_plot, 'y (mm)');
%     axis equal;
%     set(ext_coeff_plot, 'XLim', [x(1) x(end)])
%     set(ext_coeff_plot, 'YLim', [y(1) y(end)]);
% catch e
%     fprintf(['No fitdata found! \n', ...
%         'Fitdata can be included as: \n', ...
%         '[fitdata.fitresult, fitdata.gof]',...
%         ' = fit_transmission(...)\n']);
% end



end