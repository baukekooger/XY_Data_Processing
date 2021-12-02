function draw_lines_wavelength_range(obj, src)
% Draw lines in the plotwindow indicating the wavelength range to be
% selected. 
    if strcmp(obj.experiment, 'transmission')
        draw_lines_transmission(obj)
    elseif strcmp(obj.experiment, 'excitation_emission') 
        draw_lines_excitation_emission(obj, src)
    else
        error('Invalid experiment draw wavelength range')
    end
    
end

function draw_lines_transmission(obj)
    minwl = obj.datapicker.MinWavelengthSpinner.Value; 
    maxwl = obj.datapicker.MaxWavelengthSpinner.Value; 
    plot_lines(obj, minwl, maxwl)
end

function draw_lines_excitation_emission(obj, src)
    spectratype = obj.datapicker.SpectraDropDown.Value; 
    switch src.Tag
        case {'MinWavelengthSpinner', 'MaxWavelengthSpinner'}
            % don't draw the range lines in excitation mode. 
            if strcmp(spectratype, 'Excitation')
                return
            end
            minwl = obj.datapicker.MinWavelengthSpinner.Value; 
            maxwl = obj.datapicker.MaxWavelengthSpinner.Value; 
            plot_lines(obj, minwl, maxwl)
        case {'EmissionPeakSpinner', 'PeakWidthSpinner'}
            % don't draw the range lines in excitation mode. 
            if strcmp(spectratype, 'Excitation')
                return
            end
            peakwl = obj.datapicker.EmissionPeakSpinner.Value; 
            peakwidth = obj.datapicker.PeakWidthSpinner.Value; 
            wls = obj.plotdata.wavelengths_emission;
            minwl = select_nearest(wls, (peakwl - peakwidth/2)); 
            maxwl = select_nearest(wls, (peakwl + peakwidth/2)); 
            plot_lines(obj, minwl, maxwl)  
        case {'MinExWavelengthSpinner', 'MaxExWavelengthSpinner'}
            % don't draw the range lines in excitation mode. 
            if strcmp(spectratype, 'Emission')
                return
            end
            minwl = obj.datapicker.MinExWavelengthSpinner.Value; 
            maxwl = obj.datapicker.MaxExWavelengthSpinner.Value; 
            plot_lines(obj, minwl, maxwl)
    end
end

function plot_lines(obj, minvalue, maxvalue)
% Plot a lines denoting a selection in the spectrum plot. 

    % Remove the old lines 
    delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'ConstantLine'))
    	
    % Plot the new lines. If min and max the same, plot only one line. 
    if minvalue == maxvalue 
        linemiddle = xline(obj.plotwindow.ax_spectrum, minvalue); 
        linemiddle.Label = 'only here'; 
        linemiddle.LabelVerticalAlignment = 'middle';
        linemiddle.LabelHorizontalAlignment = 'right'; 
        if not(isempty(obj.plotwindow.ax_spectrum.Legend))
            obj.plotwindow.ax_spectrum.Legend.String = ...
                obj.plotwindow.ax_spectrum.Legend.String(1:end-1); 
        end
    else
        linestart = xline(obj.plotwindow.ax_spectrum, minvalue); 
        linestart.Label = 'from here'; 
        linestart.LabelVerticalAlignment = 'middle';
        linestart.LabelHorizontalAlignment = 'right'; 
        
        linestop = xline(obj.plotwindow.ax_spectrum, maxvalue); 
        linestop.Label = 'till here'; 
        linestop.LabelVerticalAlignment = 'middle';
        linestop.LabelHorizontalAlignment = 'left';
        % remove the new legend entries
        if not(isempty(obj.plotwindow.ax_spectrum.Legend))
            obj.plotwindow.ax_spectrum.Legend.String = ...
                obj.plotwindow.ax_spectrum.Legend.String(1:end-2); 
        end
        
    end
    
end

