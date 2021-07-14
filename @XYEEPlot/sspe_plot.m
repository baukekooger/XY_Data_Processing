function [ obj ] = sspe_plot( obj )
%SSPE_PLOT Plot of a single-position emission spectrum
%   Opens two windows, one with a datapicker and one with a full
%   plotwindow. The data selected within the datapicker is diplayed in the
%   other window.

% Process the nessecary data
power = squeeze(obj.XYEEobj.power);
spectrum = squeeze(obj.XYEEobj.spectrum);

% Set up the windows
datapicker = figure();
display = figure();
dcm = datacursormode(datapicker);
set(dcm, 'UpdateFcn', @updateDisplay);

% Setup the display window
figure(display);
spectrum_ax = subplot(3,3,[1,2,4,5]);
imagesc(obj.XYEEobj.em_wl, obj.XYEEobj.ex_wl, spectrum);
% set(spectrum_ax, 'YDir', 'normal');
xlabel('Emission wavelength (nm)');
ylabel('Excitation wavelength (nm)');

ex_plot = subplot(3,3, [3,6]);
plot(NaN, NaN);
ylabel('Excitation wavelength (nm)');
xlabel('Intensity (a.u.)');

em_plot = subplot(3,3, [7,8]);
plot(NaN, NaN);
ylabel('Intensity (a.u.)');
xlabel('Emission wavelength (nm)');

power_plot = subplot(3,3,9);
plot(obj.XYEEobj.ex_wl, power*1e6);
set(power_plot, 'XLim', [obj.XYEEobj.ex_wl(1) obj.XYEEobj.ex_wl(end)]);
xlabel('Excitation wavelength (nm)');
ylabel('Power (\muW)');

linkaxes([spectrum_ax em_plot], 'x');
linkaxes([spectrum_ax ex_plot], 'y');

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

figure(datapicker);
h = imagesc(spectrum);
datapicker_ax = h.Parent;
% set(datapicker_ax, 'YDir', 'normal');
linkprop([spectrum_ax datapicker_ax],'CLim');
    
    function text = updateDisplay(~, event_obj)
        if isMultipleCall();  return;  end
        ci = dcm.getCursorInfo();
        ii=1;
        try
            while length(spectrum_ax.Children)>1
                if isa(spectrum_ax.Children(ii), 'matlab.graphics.chart.primitive.Line')
                    delete(spectrum_ax.Children(ii));
                else
                    ii=ii+1;
                end
            end
        catch e
            disp(ii)
            disp(spectrum_ax.Children);
            disp(e)
        end
        for ii=1:length(ci)
            pos = ci(ii).Position;

            plot(ex_plot, spectrum(:, pos(1) ), obj.XYEEobj.ex_wl);
            hold(ex_plot, 'on');
            
            plot(em_plot, obj.XYEEobj.em_wl, spectrum(pos(2), :));
            hold(em_plot, 'on');
            
            c_ex_wl = obj.XYEEobj.em_wl(pos(1));
            c_em_wl = obj.XYEEobj.ex_wl(pos(2));
            hold(spectrum_ax, 'on');
            plot(spectrum_ax, [0 2000], [c_em_wl c_em_wl], 'color', ...
            [ex_plot.Children(1).Color 0.8], 'linewidth', 0.1);
            plot(spectrum_ax, [c_ex_wl c_ex_wl], [0 2000], 'color', ...
                [em_plot.Children(1).Color 0.8], 'linewidth', 0.1);
        end
        hold(spectrum_ax, 'off');
        hold(ex_plot, 'off');
        hold(em_plot, 'off');
        
        positions = struct2cell(ci);
        positions = cell2mat(positions(2,1,:));
        n = numel(positions)/2;
        lem = cell(n,1);
        lex = cell(n,1);
        try
            for ii = 1:n
                a = squeeze(positions(:, :, ii));
                b = a(1);
                a = a(2);
                sa = [num2str(obj.XYEEobj.ex_wl(a)) ' nm'];
                sb = [num2str(obj.XYEEobj.em_wl(b)) ' nm'];
                lem{ii} = sa;
                lex{ii} = sb;
            end
        catch e
            disp(e)
        end
        legend(em_plot, lem);
        legend(ex_plot, lex);
        
        ylabel(em_plot, 'Intensity (a.u.)');
        xlabel(em_plot, 'Wavelength (nm)');
        set(em_plot, 'YLim', spectrum_ax.CLim * 1.5);
        set(em_plot, 'XLim', ...
            [min(obj.XYEEobj.em_wl) max(obj.XYEEobj.em_wl)])
        set(ex_plot, 'YDir', 'reverse');
        set(ex_plot, 'XLim', spectrum_ax.CLim * 1.5);
        set(ex_plot, 'YLim', ...
            [min(obj.XYEEobj.ex_wl) max(obj.XYEEobj.ex_wl)])
        xlabel(ex_plot, 'Intensity (a.u.)');
        ylabel(ex_plot, 'Wavelength (nm)');
        
        text = sprintf('X: %.3f\nY: %.3f\nval: %.3E', event_obj.Position(1), ...
            event_obj.Position(2), ...
            spectrum(event_obj.Position(2), event_obj.Position(1)) );
    end

end

