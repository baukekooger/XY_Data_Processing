function fit_all_decay(obj)
% function which fits all the datapoints
% possibly lengthy procedure, so disable ui components and launch
% progressbar
% enable everything when fitting is complete 
% make the plotoptions and enable plotoptions when all is fitted. 
    
    progressbar('Fitting');
    enable_gui(obj, 'off') 
    
    ynum = obj.xystage.ynum; 
    xnum = obj.xystage.xnum; 
    [wls, ~] = get_excitation_wavelengths(obj); 
    wlnum = length(wls);
    total_points = double(xnum * ynum * wlnum); 
    
    counter = 1; 
    for ii = 1:ynum
        for jj = 1:xnum
            for kk = 1:wlnum
                if not(isempty(obj.fitdata.fitobjects{ii, jj, kk}))
                    frac = counter/total_points; 
                    progressbar(frac);
                    counter = counter +1;
                    continue
                end
                fit_single_trace_decay(obj, ii, jj, kk);
                frac = counter/total_points; 
                progressbar(frac);
                counter = counter +1; 
            end
        end
    end 
    
    enable_gui(obj, 'on') 
    set_plotmethods_fitted_data(obj)

end

