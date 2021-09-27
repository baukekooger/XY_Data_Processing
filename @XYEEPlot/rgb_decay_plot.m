function [ obj ] = rgb_decay_plot( obj )

spectrum = obj.XYEEobj.digitizer.spectra;

% Redefine subplot
% opt = {0.01, 0.01, 0.5};
% subplot = @(m,n,p) subtightplot(m,n,p,opt{:}); 

% Set up the windows
datapicker = figure();
display = figure();
dcm = datacursormode(datapicker);
set(dcm, 'UpdateFcn', @updateDisplay);

% Setup the display window
figure(display);
spectrum_plot = subplot(1,4,1:2);
qy_plot = subplot(1,4,4);
rgb_plot = subplot(1,4,3);
x = squeeze(obj.XYEEobj.xystage.coordinates(:,1,1));
y = squeeze(obj.XYEEobj.xystage.coordinates(1,:,2));

% IMAGESC is defined as (y,x), so a permutation is in order.

tau_mean = permute(obj.rgb/1e3, [2 1 3]);
tau_mean = squeeze(tau_mean(:,:,1));

% disp('Custom contour values set!');
% v = 0.35:0.05:1.5;
% tau_mean(tau_mean<0.4) = nan;
% tau_mean(tau_mean>1.3) = nan;

imagesc(x,y,tau_mean);
hold all;
try
    [C, h] = contour(x,y,tau_mean, v, 'color','k');
    clabel(C, h, 'FontSize', 10);
catch e
    disp(e.message)
end
set(rgb_plot, 'YAxisLocation', 'left');
colormap(rgb_plot, 'viridis');
xlabel(rgb_plot, 'x (mm)');
ylabel(rgb_plot, 'y (mm)');
xstep = (max(x) - min(x))/size(obj.rgb,1);
ystep = (max(y) - min(y))/size(obj.rgb,2);
axis equal;
hold off;
try
    disp('Adding quantum yield estimate based on average decay time!');
    tau_ideal = cellfun(@(x)(-log(x(1)/x(0))), obj.XYEEobj.fitdata.fit,...
        'UniformOutput', false);
    tau_ideal = cell2mat(tau_ideal);
    tau_ideal(obj.XYEEobj.fitdata.gofs<0.99) = nan;
    tau_ideal_mean = nanmean(flatmat(tau_ideal));
    tau_ideal_std = nanstd(flatmat(tau_ideal));
    
    tau_ideal(tau_ideal> (4*tau_ideal_std+tau_ideal_mean)) = nan;
    tau_ideal(tau_ideal< (-4*tau_ideal_std+tau_ideal_mean)) = nan;
    
    tau_ideal_mean = nanmean(flatmat(tau_ideal));
    tau_ideal_std = nanstd(flatmat(tau_ideal));
    
    fprintf('tau_ideal = %.3f pm %.3f us; max at %.3f\n', tau_ideal_mean, ...
        tau_ideal_std, fullmax(tau_ideal));
    
    axes(qy_plot);
    qy = tau_mean ./ tau_ideal_mean;
    imagesc(x,y,qy);
    colormap(qy_plot, 'hot');
    caxis([0.5 1]);
    hold all;
    [C, h] = contour(x,y,qy, v, 'color','k');
    clabel(C, h, 'FontSize', 10);
    xlabel(qy_plot, 'x (mm)');
    axis equal;
    hold off;
    linkaxes([rgb_plot, qy_plot],'xy');
catch e
    disp(e.message);
end

try
    set(rgb_plot, 'XLim', [min(x) max(x)] + [-xstep, xstep]/2);
    set(rgb_plot, 'YLim', [min(y) max(y)] + [-ystep, ystep]/2);
    set(qy_plot, 'XLim', [min(x) max(x)] + [-xstep, xstep]/2);
    set(qy_plot, 'YLim', [min(y) max(y)] + [-ystep, ystep]/2);
catch e
    disp(e.message);
end

% Align the position correctly
updatePlotSize();
set(display, 'SizeChangedFcn', @updatePlotSize);

% Set up the datapicker window
figure(datapicker);
h = imagesc(tau_mean);
datapicker_ax = h.Parent;
axis equal;
try
    set(datapicker_ax, 'XLim', [0.5 numel(x)+0.5]);
    set(datapicker_ax, 'YLim', [0.5 numel(y)+0.5]);
catch
end

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

set(spectrum_plot, 'YLim', [0 1]);
set(spectrum_plot, 'YScale', 'log');
set(spectrum_plot, 'XLim', [-0.1 10]);

% Add (a), (b) labels
text(0.02,0.98,'(a)', 'color', 'k','Units', 'Normalized', ...
    'VerticalAlignment', 'Top', 'Parent', spectrum_plot);
text(0.02,0.98,'(b)', 'color', 'w','Units', 'Normalized', ...
    'VerticalAlignment', 'Top', 'Parent', rgb_plot);

    function displayText = updateDisplay(~, event_obj)
        if isMultipleCall();  return;  end
        ci = dcm.getCursorInfo();
        % Delete all lines in the rgb plot
        ii=1;
        try
            while (length(rgb_plot.Children)>1 && ii<(length(rgb_plot.Children)-1) )
                if isa(rgb_plot.Children(ii), 'matlab.graphics.chart.primitive.Line') || ...
                        isa(rgb_plot.Children(ii), 'matlab.graphics.chart.primitive.Scatter')
                    
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
        xlimit = get(spectrum_plot, 'XLim');
        yscale = get(spectrum_plot, 'YScale');
        for ii=1:length(ci)
            pos = ci(ii).Position;
            try
                l = plot(spectrum_plot, squeeze(obj.XYEEobj.time(pos(1), pos(2),:))/1e3, ...
                    squeeze(spectrum(pos(1), pos(2), 1, :, :))', '-');
                for jj=1:length(l)
                    tau = obj.rgb(pos(1), pos(2), jj+1)/1e3;
                    l(jj).DisplayName = sprintf(['\\tau_{mean}' ...
                        '= %.2f \\mus'], tau);
                end
            catch e
                disp(e);
                disp(e.stack);
            end
                        
            xd = x(pos(1));
            yd = y(pos(2));
            hold(rgb_plot, 'on');
            try
                scatter(rgb_plot, xd, yd, 15, 'filled',...
                    'MarkerFaceColor', [spectrum_plot.Children(1).Color], ...
                    'MarkerEdgeColor', 'w');
            catch e
                disp(e.message);
            end
            
            hold(spectrum_plot, 'on');
            try
                plotFittedData(pos(1), pos(2), spectrum_plot);
            catch e
%                 disp(e.message);
            end
%             plot(rgb_plot, xd, yd, 'kx', ...
%                 'markersize', 3);
        end
        hold(rgb_plot, 'off');
        hold(spectrum_plot, 'off');
        
        xlabel(spectrum_plot, 'Time (\mus)');
        ylabel(spectrum_plot, 'Intensity (a.u.)');
        set(spectrum_plot, 'YLim', ylimit);
        set(spectrum_plot, 'XLim', xlimit);
        set(spectrum_plot, 'YScale', yscale);
        legend(spectrum_plot,'show');
        
        text(0.02,0.98,'(a)','color', 'k','Units', 'Normalized', ...
            'VerticalAlignment', 'Top', 'Parent', spectrum_plot);
        
        displayText = sprintf('X: %.3f\nY: %.3f', event_obj.Position(1), ...
            event_obj.Position(2));
    end

    function plotFittedData(x, y, plothandle)
%         m = cellfun(@(fit)( fit(squeeze(obj.XYEEobj.time(x,y,:))) ), obj.XYEEobj.fitdata, ...
%             'UniformOutput', false);
        ft = obj.XYEEobj.fitdata.fit{x,y};
        t = flatmat(obj.XYEEobj.time(x,y,:)/1e3);
        m = ft(t);
%         m = squeeze(cell2mat(m));
        sz = size(m);
        nColors = size(get(plothandle,'ColorOrder'), 1);
        cooi = mod(plothandle.ColorOrderIndex - sz(end) - 1, nColors) + 1;
        plothandle.ColorOrderIndex = cooi;
        if cooi == nColors
            plot(plothandle, t, m, '--', 'color', 'k');
        else
            plot(plothandle, nan,nan);
        end
    end

    function updatePlotSize(hObject, event)
        spectrum_plot_pos = plotboxpos(spectrum_plot);
        rgb_plot_pos = plotboxpos(rgb_plot);
%         set(qy_plot, 'Position', rgb_plot_pos.*[0 1 1 1] + ...
%             [spectrum_plot_pos(1) + spectrum_plot_pos(3) - rgb_plot_pos(3) 0 0 0]);
%         set(rgb_plot, 'Position', rgb_plot_pos .* [0 1 0 1] + ...
%             spectrum_plot_pos .* [1 0 0.5 0]);
        delete(findall(rgb_plot.Children,'type', 'Text'));
        delete(findall(spectrum_plot.Children,'type', 'Text'));
        delete(findall(qy_plot.Children,'type', 'Text'));
        
        text(0.95,0.98,'(a)','color', 'k','Units', 'Normalized', ...
            'VerticalAlignment', 'Top', 'Parent', spectrum_plot);
        text(0.02,0.98,'(b)','color', 'w','Units', 'Normalized', ...
            'VerticalAlignment', 'Top', 'Parent', rgb_plot);
        text(0.02,0.98,'(c)','color', 'w','Units', 'Normalized', ...
            'VerticalAlignment', 'Top', 'Parent', qy_plot);
        
    end

end