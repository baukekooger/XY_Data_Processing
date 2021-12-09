function fit_all_excitation_emission(obj)
% Fit all the datapoints for either emission or excitation with the current
% fittype. 
% Progressbar indicates progress on this lengthy procedure. 

    progressbar('Fitting');

    ynum = obj.xystage.ynum; 
    xnum = obj.xystage.xnum; 
    switch obj.datapicker.SpectraDropDown.Value
        case 'Emission'
            [wls, ~] = get_excitation_wavelengths(obj); 
            wlnum = length(wls);
        case 'Excitation'
            wlnum = 1; 
    end

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
                switch obj.datapicker.SpectraDropDown.Value
                    case 'Emission'
                        fit_single_emission(obj, ii, jj, kk);
                    case 'Excitation'
                        fit_single_excitation(obj, ii, jj);
                end
                frac = counter/total_points; 
                progressbar(frac);
                counter = counter + 1; 
            end
        end
    end 

end