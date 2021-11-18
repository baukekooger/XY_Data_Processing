function set_compression_factors(obj)
% Set the possible compressionfactors. In the measurement software, the
% data can only be increased by powers of two. Therefore compression will
% be powers of two. 

    highest_power = get_highest_power_two(obj.digitizer.samples); 
    
    powers = 0:highest_power; 
    compression = 2.^powers; 
    compression = string(compression); 
    compression(1) = "none"; 
    
    obj.datapicker.DataCompressionDropDown.Items = compression; 

end

