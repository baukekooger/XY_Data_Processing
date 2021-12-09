function show_fitdata_table(obj, cursor_info)
% show the information about the fits selected with the cursor in the
% table of the datapicker.     

    fulltable = table(); 
    for ii = 1:length(cursor_info)
        switch obj.experiment
            case 'transmission'
                if isempty(fulltable)
                    fulltable = ...
                        single_entry_transmission(obj, cursor_info, ii);    
                else
                    fulltable = [fulltable; ...
                        single_entry_transmission(obj, cursor_info, ii)]; 
                end
            case 'excitation_emission' 
                if strcmp(obj.datapicker.SpectraDropDown.Value, ... 
                        'Emission') 
                    [wls, ~] = get_excitation_wavelengths(obj);
                    for jj = 1:length(wls)
                        if isempty(fulltable)
                            fulltable = ...
                            single_entry_emission(obj, cursor_info, ii, ...
                            wls(jj), jj);
                        else
                            fulltable = [fulltable; ...
                            single_entry_emission(obj, cursor_info, ii, ...
                            wls(jj), jj)];
                        end
                    end
                elseif strcmp(obj.datapicker.SpectraDropDown.Value, ... 
                        'Excitation')
                    if isempty(fulltable)
                        fulltable = ...
                        single_entry_excitation(obj, cursor_info, ii);
                    else
                        fulltable = [fulltable; ...
                            single_entry_excitation(obj, cursor_info, ii)];
                    end
                end 
            case 'decay' 
                [wls, ~] = get_excitation_wavelengths(obj);
                for jj = 1:length(wls)
                    if isempty(fulltable)
                        fulltable = ...
                        single_entry_decay(obj, cursor_info, ii, ...
                        wls(jj), jj);
                    else
                        fulltable = [fulltable; ...
                        single_entry_decay(obj, cursor_info, ii, ...
                        wls(jj), jj)];
                    end
                end
        end
    end

% set this data in the table of the ui 
obj.datapicker.UITable.Data = fulltable; 
obj.datapicker.UITable.ColumnName = fulltable.Properties.VariableNames; 

end

function single_entry = single_entry_transmission(obj, cursor_info, ...
    index_cursor)
    
    % Table entry for transmission fit parameters. 
    [x, idx, y, idy] = get_cursor_position(obj, cursor_info, index_cursor); 

    name_index = {'pos X', 'pos Y'}; 
    xval = string(num2str(x, '%.1f')); 
    yval = string(num2str(y, '%.1f')); 
    values_index = [xval, yval]; 
    table_index = table(values_index); 
    table_index = splitvars(table_index);
    table_index.Properties.VariableNames = name_index; 

    names_coefficients = coeffnames(...
        obj.fitdata.fitobjects{idy, idx});
    names_coefficients = ['thickness'; 'refractive index (589nm)'; ...
        names_coefficients(1:7)];
    values_coefficients = ...
        coeffvalues(obj.fitdata.fitobjects{idy, idx});   
    thickness = values_coefficients(8); 
    
    % Get refractive index from sellmeier equation. 
    n1 = @(a, b, x)( sqrt( 1 + a .* x.^2 ./ (x.^2 - b.^2)));
    refractive_index = n1(values_coefficients(1), ...
        values_coefficients(2), 589); 
                
    values_coefficients = values_coefficients(1:7); 
    values_coefficients = [thickness, refractive_index, ...
        values_coefficients]; 

    table_coefficients = table(values_coefficients); 
    table_coefficients = splitvars(table_coefficients); 
    table_coefficients.Properties.VariableNames = names_coefficients; 
  
    table_goodness = struct2table(obj.fitdata.goodnesses{idy, idx}); 
    single_entry = [table_index, table_coefficients, table_goodness]; 

end

function single_entry = single_entry_emission(obj, cursor_info, ...
    index_cursor, wl, jj)
    % Table entry for emission fit parameters. 
 
    [x, idx, y, idy] = get_cursor_position(obj, cursor_info, index_cursor); 

    name_index = {'pos X', 'pos Y', 'ex wl'}; 
    xval = string(num2str(x, '%.1f')); 
    yval = string(num2str(y, '%.1f')); 
    wlval = string(num2str(wl, '%.0f')); 
    values_index = [xval, yval, wlval]; 
    table_index = table(values_index); 
    table_index = splitvars(table_index);
    table_index.Properties.VariableNames = name_index; 

    names_coefficients = coeffnames(...
        obj.fitdata.fitobjects{idy, idx, jj});
    values_coefficients = ...
        coeffvalues(obj.fitdata.fitobjects{idy, idx, jj});      
    
    table_coefficients = table(values_coefficients); 
    table_coefficients = splitvars(table_coefficients); 
    table_coefficients.Properties.VariableNames = names_coefficients; 
    
    table_goodness = struct2table(obj.fitdata.goodnesses{idy, idx, ...
        jj}); 
    
    single_entry = [table_index, table_coefficients, table_goodness]; 
end

function single_entry = single_entry_excitation(obj, cursor_info, ...
    index_cursor)
    % Table entry for excitation fit parameters. 
    [x, idx, y, idy] = get_cursor_position(obj, cursor_info, index_cursor); 

    name_index = {'pos X', 'pos Y'}; 
    xval = string(num2str(x, '%.1f')); 
    yval = string(num2str(y, '%.1f')); 
    values_index = [xval, yval]; 
    table_index = table(values_index); 
    table_index = splitvars(table_index);
    table_index.Properties.VariableNames = name_index; 

    names_coefficients = coeffnames(...
        obj.fitdata.fitobjects{idy, idx});
    values_coefficients = ...
        coeffvalues(obj.fitdata.fitobjects{idy, idx});      
    
    table_coefficients = table(values_coefficients); 
    table_coefficients = splitvars(table_coefficients); 
    table_coefficients.Properties.VariableNames = names_coefficients; 
  
    table_goodness = struct2table(obj.fitdata.goodnesses{idy, idx}); 
    single_entry = [table_index, table_coefficients, table_goodness]; 
end

function single_entry = single_entry_decay(obj, cursor_info, ...
    index_cursor, wl, jj)
    % Table entry for decay fit parameters

    [x, idx, y, idy] = get_cursor_position(obj, cursor_info, index_cursor); 

    name_index = {'pos X', 'pos Y', 'ex wl'}; 
    xval = string(num2str(x, '%.1f')); 
    yval = string(num2str(y, '%.1f')); 
    wlval = string(num2str(wl, '%.0f')); 
    values_index = [xval, yval, wlval]; 
    table_index = table(values_index); 
    table_index = splitvars(table_index);
    table_index.Properties.VariableNames = name_index; 

    switch obj.datapicker.FitTypeDropDown.Value
        case 'Single Exponential'
            names_coefficients = {'C'; 'tau (mircos)'};
            values_coefficients = ...
                coeffvalues(obj.fitdata.fitobjects{idy, idx, jj});
            values_coefficients(2) = -1e6/values_coefficients(2); 
        case 'Double Exponential' 
                        names_coefficients = {'C1'; 'tau1 (micros)'; ...
                            'C2'; 'tau_2 (micros)'};
            values_coefficients = ...
                coeffvalues(obj.fitdata.fitobjects{idy, idx, jj});
            values_coefficients(2) = -1e6/values_coefficients(2); 
            values_coefficients(4) = -1e6/values_coefficients(4); 
    end
    
    table_coefficients = table(values_coefficients); 
    table_coefficients = splitvars(table_coefficients); 
    table_coefficients.Properties.VariableNames = names_coefficients; 
    
    table_goodness = struct2table(obj.fitdata.goodnesses{idy, idx, ...
        jj}); 
    
    single_entry = [table_index, table_coefficients, table_goodness]; 
end






