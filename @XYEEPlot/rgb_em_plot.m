function [ obj ] = rgb_em_plot( obj )
%RGB_EM_PLOT Summary of this function goes here
%   Detailed explanation goes here

% Process the necessary data
% spectrum = reshape(obj.XYEEobj.spectrum(:,:,1,:),...
%     size(obj.XYEEobj.spectrum,1),...
%     size(obj.XYEEobj.spectrum,2),...
%     size(obj.XYEEobj.spectrum,4));
spectrum = squeeze(obj.XYEEobj.spectrum);
% spectrum = shiftdim(spectrum, ndims(spectrum)-1);

% Set up the windows
datapicker = figure();
display = figure();
dcm = datacursormode(datapicker);
set(dcm, 'UpdateFcn', @updateDisplay);

% Setup the display window
figure(display);
spectrum_plot = subplot(3,3,1:6);

rgb_plot = subplot(3,3,7);
x = squeeze(obj.XYEEobj.xycoords(:,1,1));
y = squeeze(obj.XYEEobj.xycoords(1,:,2));
% IMAGESC is defined as (y,x), so a permutation is in order.
imagesc(x,y,permute(obj.rgb, [2 1 3]));
xlabel(rgb_plot, 'x (mm)');
ylabel(rgb_plot, 'y (mm)');
axis equal;
dx = max([mean(diff(x)), 1]);
dy = max([mean(diff(y)), 1]);
set(rgb_plot, 'XLim', [min(x)-dx/2 max(x)+dx/2]);
set(rgb_plot, 'YLim', [min(y)-dy/2 max(y)+dy/2]);

intensity_plot = subplot(3,3,8);
sp = shiftdim(spectrum, 2);
% sp = spectrum;
inx = ((obj.XYEEobj.em_wl>1050) & (obj.XYEEobj.em_wl<1200));
if ~sum(inx)
    inx = true(size(obj.XYEEobj.em_wl));
end
I = squeeze(trapz(obj.XYEEobj.em_wl(inx), sp(inx,:,:)));
I = permute(I, [2 1]);
imagesc(x-fullmin(x), y-fullmin(y), I);
xlabel(intensity_plot, 'x (mm)');
ylabel(intensity_plot, 'y (mm)');
axis equal;
% set(intensity_plot, 'XLim', [min(x)-dx/2 max(x)+dx/2]);
% set(intensity_plot, 'YLim', [min(y)-dy/2 max(y)+dy/2]);
x = x-fullmin(x);
y = y-fullmin(y);
set(intensity_plot, 'XLim', [-dx/2 max(x)+dx/2]);
set(intensity_plot, 'YLim', [-dy/2 max(y)+dy/2]);


xy_plot = subplot(3,3,9);
X = squeeze(obj.xyl(:,:,1));
X = reshape(X,numel(X),1);
Y = squeeze(obj.xyl(:,:,2));
Y = reshape(Y,numel(Y),1);
cieplot();
hold all;
scatter(X,Y,'k');
hold off;
set(xy_plot, 'XLim', [0 1]);
set(xy_plot, 'YLim', [0 1]);
set(xy_plot, 'PlotBoxAspectRatio', [1 1 1]);

% Setup the datapicker window
figure(datapicker);
h = imagesc(permute(obj.rgb, [2 1 3]));
datapicker_ax = h.Parent;
axis equal;
set(datapicker_ax, 'XLim', [0.5 numel(x)+0.5]);
set(datapicker_ax, 'YLim', [0.5 numel(y)+0.5]);

% Reverse all x-directions
set(datapicker_ax, 'XDir', 'reverse');
set(intensity_plot, 'XDir', 'reverse');
set(rgb_plot, 'XDir', 'reverse');

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
ylimit = nanmax(reshape(spectrum, numel(spectrum), 1));
set(spectrum_plot, 'YLim', [0 ylimit]);
xlimit = [obj.XYEEobj.em_wl(1) obj.XYEEobj.em_wl(end)];
set(spectrum_plot, 'XLim', xlimit);

    function text = updateDisplay(~, event_obj)
        if isMultipleCall();  return;  end
        ci = dcm.getCursorInfo();
        % Delete all lines in the rgb plot
        ii=1;
        try
            while length(intensity_plot.Children)>1
                if isa(intensity_plot.Children(ii), 'matlab.graphics.chart.primitive.Line')
                    delete(intensity_plot.Children(ii));
                else
                    ii=ii+1;
                end
            end
        catch e
            disp(ii)
            disp(intensity_plot.Children);
            disp(e)
        end
        % Append to the spectrum, and draw lines
        ylimit = get(spectrum_plot, 'YLim');
        yscale = get(spectrum_plot, 'YScale');
        xlimit = get(spectrum_plot, 'XLim');
        for ii=1:length(ci)
            pos = ci(ii).Position;

            plot(spectrum_plot, obj.XYEEobj.em_wl, squeeze(spectrum(pos(1), pos(2), :)) );
            hold(spectrum_plot, 'on');
            try
                plotFittedData(pos(1), pos(2), spectrum_plot);
            catch
            end
            
            xd = x(pos(1));
            yd = y(pos(2));
            hold(intensity_plot, 'on');
            plot(intensity_plot, xd, yd, 'o', 'color', 'k', ...
                'markersize', 5, 'MarkerFaceColor', ...
                [spectrum_plot.Children(1).Color]);
%             plot(rgb_plot, xd, yd, 'kx', ...
%                 'markersize', 3);
        end
        hold(intensity_plot, 'off');
        hold(spectrum_plot, 'off');
        
        xlabel(spectrum_plot, 'Wavelength (nm)');
        ylabel(spectrum_plot, 'Intensity (a.u.)');
        set(spectrum_plot, 'YLim', ylimit);
        set(spectrum_plot, 'YScale', yscale);
        set(spectrum_plot, 'XLim', xlimit);
        
        text = sprintf('X: %.3f\nY: %.3f', event_obj.Position(1), ...
            event_obj.Position(2));
    end

    function plotFittedData(x, y, plothandle)
        % Fitted data is defined on an energy scale, so correct for that
        wl = obj.XYEEobj.em_wl;
        E = 1240./wl;
        m = obj.XYEEobj.fitdata{x,y}.model;
        m = fliplr(m);
        m = m'./(wl.^2);
        c = [plothandle.Children(1).Color 0.75];
        lines = {'--', '-.', ':'};
        cooi = plothandle.ColorOrderIndex;
        ls = size(obj.XYEEobj.fitdata{x,y}.Area, 2);
        for ii=1:ls
            center = obj.XYEEobj.fitdata{x,y}.Center(1, ii);
            height = obj.XYEEobj.fitdata{x,y}.Height(1, ii);
            width = obj.XYEEobj.fitdata{x,y}.Width(1, ii);
            g = PeakFit.fngaussian(E, center, height, width);
            g = g./(wl.^2);
            plot(plothandle, wl, g, 'linestyle',  lines{mod(ii-1, length(lines))+1},...
                'color', c)
        end
        plot(plothandle, wl, m, 'k-')%, 'color', c);
        plothandle.ColorOrderIndex = cooi;
    end

end

