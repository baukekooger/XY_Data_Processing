function [obj] = read_attributes(obj)
% reads the attributes of the measurement file such as the comments,
% substrate used and instrument settings  
% modify this file if new attributes are added in the experiment software

obj.comment = h5readatt(obj.fname, ['/' obj.experimentname], 'comment');

settingsinfo = h5info(obj.fname, ['/' obj.experimentname '/settings']); 
instrumentfolders = {settingsinfo.Groups.Name}; 

instruments = cell(1,length(instrumentfolders));
for ii = 1:length(instruments) 
    instruments{ii} = erase(instrumentfolders{ii}, ...
        ['/' obj.experimentname '/settings/']); 
    switch instruments{ii}
        case 'digitizer'
            obj.digitizer.type = 'not implemented yet';
            obj.digitizer.active_channels = ...
                h5readatt(obj.fname, ['/' obj.experimentname '/settings/digitizer'], 'active_channels');
            obj.digitizer.post_trigger_size = h5readatt(obj.fname, ...
                ['/' obj.experimentname '/settings/digitizer'], 'post_trigger_size');
            obj.digitizer.sample_period = 'not implemented yet'; 
            obj.digitizer.samples = h5readatt(obj.fname, ...
                ['/' obj.experimentname '/settings/digitizer'], 'samples');
        case 'spectrometer'
            obj.spectrometer.fiber = 'not implemented yet'; 
            obj.spectrometer.integration_time = h5readatt(obj.fname, ...
                ['/' obj.experimentname '/settings/spectrometer'], 'integrationtime');
            obj.spectrometer.averageing = h5readatt(obj.fname, ...
                ['/' obj.experimentname '/settings/spectrometer'], 'average_measurements');
            obj.spectrometer.type = h5readatt(obj.fname, ...
                ['/' obj.experimentname '/settings/spectrometer'], 'spectrometer');
        case 'xystage' 
            obj.xystage.xnum = h5readatt(obj.fname, ...
                ['/' obj.experimentname '/settings/xystage'], 'xnum');
            obj.xystage.ynum = h5readatt(obj.fname, ...
                ['/' obj.experimentname '/settings/xystage'], 'ynum');
        case 'laser'
            obj.laser.wlnum = h5readatt(obj.fname, ...
                ['/' obj.experimentname '/settings/laser'], 'wlnum');
            obj.laser.energy_level = h5readatt(obj.fname, ...
                ['/' obj.experimentname '/settings/laser'], 'energylevel');
    end
end

end

