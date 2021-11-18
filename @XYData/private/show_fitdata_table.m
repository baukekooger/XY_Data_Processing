function show_fitdata_table(obj, cursor_info)
% show the information about the fits selected with the cursor in the
% table of the datapicker. 
 
% obj.datapicker.UITable 
[wls, index_wls] = get_excitation_wavelengths(obj); 

fulltable = table(); 
for ii = 1:length(cursor_info)
    for jj = 1:length(index_wls) 
        if isempty(fulltable)
            fulltable = ...
                single_entry_fittable(obj, cursor_info, ii, wls(jj), ...
                index_wls(jj));
        else
            fulltable = [fulltable ; ...
                single_entry_fittable(obj, cursor_info, ii, wls(jj), ...
                index_wls(jj))]; 
        end
    end
end

% set this data in the table of the ui 
obj.datapicker.UITable.Data = fulltable; 
obj.datapicker.UITable.ColumnName = fulltable.Properties.VariableNames; 

end

function single_entry = single_entry_fittable(obj, cursor_info, ...
    index_cursor, wl, index_wl)
% make one row of fit data for the fit data table 

    [x, idx, y, idy] = get_cursor_position(obj, cursor_info, index_cursor); 

    name_index = {'pos X', 'pos Y', 'wl'}; 
    xval = string(num2str(x, '%.1f')); 
    yval = string(num2str(y, '%.1f')); 
    wlval = string(num2str(wl, '%.0f')); 
    values_index = [xval, yval, wlval]; 
    table_index = table(values_index); 
    table_index = splitvars(table_index);
    table_index.Properties.VariableNames = name_index; 

    names_coefficients = ...
        coeffnames(obj.fitdata.fitobjects{idy, idx, index_wl});  
    values_coefficients = ...
        coeffvalues(obj.fitdata.fitobjects{idy, idx, index_wl});
    
    table_coefficients = table(values_coefficients); 
    table_coefficients = splitvars(table_coefficients); 
    table_coefficients.Properties.VariableNames = names_coefficients; 
    
    table_goodness = struct2table(obj.fitdata.goodnesses{idy, idx, ...
        index_wl}); 
    
    single_entry = [table_index, table_coefficients, table_goodness]; 

end


