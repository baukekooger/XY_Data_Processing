function  reset_fitdata(obj)
% reset the fitdata to an empty cell with the correct dimensions. 

    [ex_wls, ~] = get_excitation_wavelengths(obj); 
    wlnum = length(ex_wls); 

    obj.fitdata.fitobjects = cell(obj.xystage.ynum, ...
        obj.xystage.xnum, wlnum); 
    obj.fitdata.goodnesses = cell(obj.xystage.ynum, ...
        obj.xystage.xnum, wlnum); 
    obj.fitdata.outputs = cell(obj.xystage.ynum, ...
        obj.xystage.xnum, wlnum);
end

