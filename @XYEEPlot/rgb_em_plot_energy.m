function [ obj ] = rgb_em_plot_energy( obj )
%RGB_EM_PLOT Summary of this function goes here
%   Detailed explanation goes here

% Process the necessary data
disp('Warning! Plot Energy already normalizes and corrects the spectrum!');
spectrum = squeeze(obj.XYEEobj.spectrum);
wl = obj.XYEEobj.em_wl;
spectrum = spectrum .* permute(repmat(wl.^2,[1 size(spectrum,1) size(spectrum,2)]), ...
                    [2 3 1]);
spectrum = spectrum./repmat(max(spectrum(:,:,find(wl>350,1):end),[],3),[1 1 size(spectrum,3)]);

% Set up the windows
datapicker = figure();
display = figure();
dcm = datacursormode(datapicker);
set(dcm, 'UpdateFcn', @updateDisplay);

% Setup the display window
figure(display);
spectrum_plot = subplot(4,3,1:6);
residuals_plot = subplot(4,3,7:9);

rgb_plot = subplot(4,3,10);
x = squeeze(obj.XYEEobj.xycoords(:,1,1));
y = squeeze(obj.XYEEobj.xycoords(1,:,2));

% IMAGESC is defined as (y,x), so a permutation is in order.
imagesc(x,y,permute(obj.rgb, [2 1 3]));
xlabel(rgb_plot, 'x (mm)');
ylabel(rgb_plot, 'y (mm)');
axis equal;
set(rgb_plot, 'XLim', [min(x) max(x)]);
set(rgb_plot, 'YLim', [min(y) max(y)]);

intensity_plot = subplot(4,3,11);
sp = shiftdim(spectrum, 2);
I = squeeze(trapz(obj.XYEEobj.em_wl, sp));
I = permute(I, [2 1]);
imagesc(x, y, I);
xlabel(intensity_plot, 'x (mm)');
ylabel(intensity_plot, 'y (mm)');
axis equal;
set(intensity_plot, 'XLim', [min(x) max(x)]);
set(intensity_plot, 'YLim', [min(y) max(y)]);

xy_plot = subplot(4,3,12);
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
set(datapicker_ax, 'XLim', [1 numel(x)]);
set(datapicker_ax, 'YLim', [1 numel(y)]);

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
xlimit = sort(1240./[obj.XYEEobj.em_wl(1) obj.XYEEobj.em_wl(end)]);
set(spectrum_plot, 'XLim', xlimit);

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
        % Append to the spectrum, and draw lines
        ylimit = get(spectrum_plot, 'YLim');
        yscale = get(spectrum_plot, 'YScale');
        xlimit = get(spectrum_plot, 'XLim');
        for ii=1:length(ci)
            pos = ci(ii).Position;
            
            plot(spectrum_plot, 1240./obj.XYEEobj.em_wl, ...
                 squeeze(spectrum(pos(1), pos(2), :)));
            hold(spectrum_plot, 'on');
            try
                plotFittedData(pos(1), pos(2), spectrum_plot);
            catch
            end
            try
                plotResiduals(pos(1), pos(2));
            catch e
                if ~strcmpi(e.identifier,'MATLAB:badsubscript')
                    disp(e);
                end
            end
            hold(residuals_plot, 'on');
            
            xd = x(pos(1));
            yd = y(pos(2));
            hold(rgb_plot, 'on');
            plot(rgb_plot, xd, yd, 'o', 'color', ...
                [spectrum_plot.Children(1).Color 0.8], ...
                'markersize', 5);
            plot(rgb_plot, xd, yd, 'kx', ...
                'markersize', 3);
        end
        hold(rgb_plot, 'off');
        hold(spectrum_plot, 'off');
        
        hold(residuals_plot, 'off');
        set(residuals_plot, 'XLim', xlimit);
        
        xlabel(spectrum_plot, 'Energy (eV)');
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
        ls = numel(obj.XYEEobj.fitdata{x,y}.Center(1, :));
        c = [plothandle.Children(1).Color 0.75];
        lines = {'--', '-.', ':'};
        cooi = plothandle.ColorOrderIndex;
        for ii=1:ls
            center = obj.XYEEobj.fitdata{x,y}.Center(1, ii);
            height = obj.XYEEobj.fitdata{x,y}.Height(1, ii);
            width = obj.XYEEobj.fitdata{x,y}.Width(1, ii);
            g = PeakFit.fngaussian(E, center, height, width);
            plot(plothandle, E, g/max(m), 'linestyle', lines{mod(ii-1, ls)+1},...
                'color', c)
        end
        plot(plothandle, E, m/max(m), '-', 'color', c);
        
        plothandle.ColorOrderIndex = cooi;
    end

    function plotResiduals(x, y)
        wl = obj.XYEEobj.em_wl;
        E = 1240./wl;
        m = obj.XYEEobj.fitdata{x,y}.model;
        m = fliplr(m);
        plot(residuals_plot, E, m/max(m) - squeeze(spectrum(x,y,:))','-');
    end

end

