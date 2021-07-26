function [ obj ] = rgb_transmission_plot( obj, varargin )
%RGB_TRANSMISSION_PLOT Plots an overview of XYEE transmission data
%   Detailed explanation goes here
varargin = cellflat(varargin);
% Process the necessary data
spectrum = squeeze(obj.XYEEobj.spectrum);

% Set up the windows
datapicker = figure();
display = figure();
% display.Position = [-1200          486       829.56        327.8];
dcm = datacursormode(datapicker);
set(dcm, 'UpdateFcn', @updateDisplay);

% Setup the display window
figure(display);
if(~isempty(obj.XYEEobj.fitdata))
    spectrum_plot = subplot(3,4,1:8);
    rgb_plot = subplot(3,4,9);
    thickness_plot = subplot(3,4,10);
    ref_inx_plot = subplot(3,4,11);
    ext_coeff_plot = subplot(3,4,12);
else
    spectrum_plot = subplot(1,5,[1 2 3 4]);
    rgb_plot = subplot(1,5,5);
end

x = squeeze(obj.XYEEobj.xycoords(:,1,1));
if abs(sum(diff(x)))<0.01
    x = squeeze(obj.XYEEobj.xycoords(1,:,1));
end

y = squeeze(obj.XYEEobj.xycoords(1,:,2));
if sum(isnan(y))
    y = linspace(y(1), diff(y(1:2))*(length(y)-1)+y(1), length(y));
end
if abs(sum(diff(y)))<0.01
    y = squeeze(obj.XYEEobj.xycoords(:,1,2));
end

xm = min(x);
x = x-xm;
ym = min(y);
y = y-ym;

use_nanmat = true;
withOffset = false;
for varargin_inx=1:2:length(varargin)
    switch varargin{varargin_inx}
        case 'offset'
            x = x+varargin{varargin_inx+1}(1);
            y = y+varargin{varargin_inx+1}(2);
        case 'nanmat'
            use_nanmat = varargin{varargin_inx+1};
        case 'withoffset'
            withOffset = varargin{varargin_inx+1};
    end
end

% if no_offset
%     xm = min(x);
%     x = x-xm;
%     ym = min(y);
%     y = y-ym;
% end

% IMAGESC is defined as (y,x), so a permutation is in order.
obj.rgb=real(obj.rgb);
set(display,'CurrentAxes',rgb_plot);
imagesc(x,y,permute(obj.rgb, [2 1 3]));
xlabel(rgb_plot, 'x (mm)');
ylabel(rgb_plot, 'y (mm)');
axis equal;
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

set(rgb_plot, 'XLim', [x(1)-xdiff x(end)+xdiff]);
set(rgb_plot, 'YLim', [y(1)-ydiff y(end)+ydiff]);
set(rgb_plot, 'XTick', x);
set(rgb_plot, 'YTick', y);
xtickformat(rgb_plot,'%.1f'); 
ytickformat(rgb_plot,'%.1f'); 

try
    rsq = cellfun(@(x)(x.rsquare),obj.XYEEobj.fitdata.gof);
    d = cellfun(@(x)(x.d),obj.XYEEobj.fitdata.fitresult);
    d = permute(d, [2 1]);
    rsq = permute(rsq, [2 1]);
    nanmat = ones(size(rsq));
    if (use_nanmat); nanmat(rsq<use_nanmat) = nan; end;
    set(display,'CurrentAxes',thickness_plot);
    imagesc(x, y, d.*nanmat);
    hold all;
    contour(x, y, d.*nanmat,'color','k', 'ShowText', 'on');
    hold off;
    xlabel(thickness_plot, 'x (mm)');
    ylabel(thickness_plot, 'y (mm)');
    axis equal;
    set(thickness_plot, 'XLim', [x(1) x(end)]);
    set(thickness_plot, 'YLim', [y(1) y(end)]);

    
    n = @(a, b, x)( sqrt( 1 + a .* x.^2 ./ (x.^2 - b.^2)) );
    ref_inxs = cellfun(@(x)(n(x.an, x.bn, 589)), ...
        obj.XYEEobj.fitdata.fitresult);
    ref_inxs = permute(ref_inxs, [2 1]);
    set(display,'CurrentAxes',ref_inx_plot);
    imagesc(x, y, ref_inxs.*nanmat);
    hold all;
    contour(x, y, ref_inxs.*nanmat,'color','k', 'ShowText', 'on');
    hold off;
    xlabel(ref_inx_plot, 'x (mm)');
    ylabel(ref_inx_plot, 'y (mm)');
    axis equal;
    set(ref_inx_plot, 'XLim', [x(1) x(end)])
    set(ref_inx_plot, 'YLim', [y(1) y(end)]);
    
    
    k = @(a, b, c, d, e, x)( 1240*a .* x  .* (1./x - 1./b).^2 .* heaviside(b-x) ...
        + c + d./x + e./x.^2 );
    ext_coeffs = cellfun(@(x)(k(x.ak, x.bk, x.ck, x.dk, x.ek, 350)), ...
        obj.XYEEobj.fitdata.fitresult);
    ext_coeffs = permute(ext_coeffs, [2 1]);
    set(display,'CurrentAxes',ext_coeff_plot);
    imagesc(x, y, ext_coeffs.*nanmat);
    hold all;
    contour(x, y, ext_coeffs.*nanmat,'color','k', 'ShowText', 'on');
    hold off;
    xlabel(ext_coeff_plot, 'x (mm)');
    ylabel(ext_coeff_plot, 'y (mm)');
    axis equal;
    set(ext_coeff_plot, 'XLim', [x(1) x(end)])
    set(ext_coeff_plot, 'YLim', [y(1) y(end)]);
catch e
    fprintf(['No fitdata found! \n', ...
        'Fitdata can be included as: \n', ...
        '[XYEEobj.fitdata.fitresult, XYEEobj.fitdata.gof]',... 
        ' = fit_transmission(...)\n']);
end

% Setup the datapicker window
figure(datapicker);

h = imagesc(permute(obj.rgb, [2 1 3]));
datapicker_ax = h.Parent;
axis equal;
set(datapicker_ax, 'XTick', 1:numel(x));
set(datapicker_ax, 'YTick', 1:numel(y));
set(datapicker_ax, 'XLim', [(1-0.5) (numel(x)+0.5)]);
set(datapicker_ax, 'YLim', [(1-0.5) (numel(y)+0.5)]);

    function flag=isMultipleCall()
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

% absMin = nanmin(reshape(spectrum, numel(spectrum), 1));
% ylimit = (reshape(spectrum, numel(spectrum), 1));
% ylimit = nanmax(ylimit(100:end-100))*1.5;
ylimit = [0 1.1];
% set(spectrum_plot, 'YLim', ylimit);
set(spectrum_plot, 'XLim', [obj.XYEEobj.em_wl(1) obj.XYEEobj.em_wl(end)]);

% Reverse all x-directions
set(datapicker_ax, 'XDir', 'reverse');
try
    set(thickness_plot, 'XDir', 'reverse');
    set(ext_coeff_plot, 'XDir', 'reverse');
    set(ref_inx_plot, 'XDir', 'reverse');
catch
end
set(rgb_plot, 'XDir', 'reverse');

    function text = updateDisplay(~, event_obj)
        if isMultipleCall();  return;  end
        ci = dcm.getCursorInfo();
        % Delete all lines in the rgb plot
        ii=1;
        try
            while length(rgb_plot.Children)>1
                if isa(rgb_plot.Children(ii), 'matlab.graphics.chart.primitive.Line')
                    delete(rgb_plot.Children(ii));
                else
                    ii=ii+1;
                end
            end
        catch e
            disp(ii)
            disp(rgb_plot.Children);
            disp(e)
        end
        try
            while length(thickness_plot.Children)>1
                if isa(thickness_plot.Children(ii), 'matlab.graphics.chart.primitive.Line')
                    delete(thickness_plot.Children(ii));
                else
                    ii=ii+1;
                end
            end
        catch e
        end
        % Append to the spectrum, and draw lines
        ylimit = get(spectrum_plot, 'YLim');
        xlimit = get(spectrum_plot, 'XLim');
        yscale = get(spectrum_plot, 'YScale');
        for ii=1:length(ci)
            pos = ci(ii).Position;
            
            if(withOffset)
                plot(spectrum_plot, obj.XYEEobj.em_wl, ...
                    squeeze(spectrum(pos(1), pos(2), :)) + withOffset*(ii - 1) );
            else
                plot(spectrum_plot, obj.XYEEobj.em_wl, ...
                    squeeze(spectrum(pos(1), pos(2), :)));
            end
            hold(spectrum_plot, 'on');
            fitCounts = 1;
            try
                plotFittedData(pos(1), pos(2), spectrum_plot, ii);
                fitCounts = 2;
            catch
%                 disp(e.message);
            end
            
            xd = x(pos(1));
            yd = y(pos(2));
            hold(rgb_plot, 'on');
            plot(rgb_plot, xd, yd, 'o', 'color', ...
                [spectrum_plot.Children(1).Color 0.8], ...
                'markersize', 5);
            plot(rgb_plot, xd, yd, 'o', 'color', 'k',...
                    'markerfacecolor', spectrum_plot.Children(1).Color,...
                    'markersize', 5);
            try
                hold(thickness_plot, 'on');
                plot(thickness_plot, xd, yd, 'o', 'color', 'k',...
                    'markerfacecolor', spectrum_plot.Children(1).Color,...
                    'markersize', 5);
            catch
            end
        end
        hold(rgb_plot, 'off');
        try
            hold(thickness_plot, 'off');
        catch
        end
        hold(spectrum_plot, 'off');
        
        xlabel(spectrum_plot, 'Wavelength (nm)');
        ylabel(spectrum_plot, 'Transmittance');
%         set(spectrum_plot, 'YLim', ylimit);
        set(spectrum_plot, 'XLim', xlimit);
        set(spectrum_plot, 'YScale', yscale);
        
        text = sprintf('X: %.3f\nY: %.3f', event_obj.Position(1), ...
            event_obj.Position(2));
    end

    function plotFittedData(x, y, plothandle, index)
        wl = obj.XYEEobj.em_wl;
        c = [plothandle.Children(1).Color 0.75];
        m = obj.XYEEobj.fitdata.fitresult{x,y};
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

end