function  reset_fitdata(obj)
% reset the fitdata to an empty cell with the correct dimensions. 
    switch obj.experiment
        case 'excitation_emission'
            switch obj.datapicker.SpectraDropDown.Value
                case 'Emission'
                    [ex_wls, ~] = get_excitation_wavelengths(obj); 
                    wlnum = length(ex_wls);
                case 'Excitation'
                    wlnum = 1;
            end
        case 'decay'
            [ex_wls, ~] = get_excitation_wavelengths(obj); 
            wlnum = length(ex_wls);
    end

    obj.fitdata.fitobjects = cell(obj.xystage.ynum, ...
        obj.xystage.xnum, wlnum); 
    obj.fitdata.goodnesses = cell(obj.xystage.ynum, ...
        obj.xystage.xnum, wlnum); 
    obj.fitdata.outputs = cell(obj.xystage.ynum, ...
        obj.xystage.xnum, wlnum);
    
end

