
name = cell(1,3);
for ii = 1:length(names) 
    name{ii} = erase(names{ii}, '/decay_2109101828/settings/'); 
    switch name{ii}
        case 'digitizer'
            disp('there is a digitizer'); 
        case 'spectrometer'
            disp('there is a spectrometer')
        case 'xystage'
            disp('there is an xystage')
        case 'laser'
            disp('there is a laser') 
    end
end