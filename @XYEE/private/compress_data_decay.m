function compress_data_decay(obj)
% compress the decay data by the compression factor. 
    
    factor = obj.datapicker.DataCompressionDropDown.Value; 

    if factor == "none"
        obj.plotdata.spectra_decay = obj.digitizer.spectra; 
        obj.plotdata.time_decay = obj.digitizer.time; 
        return
    end

    factor = str2double(factor); 
    samples = double(obj.digitizer.samples); 
    sample_rate = double(obj.digitizer.sample_rate); 
    xnum = obj.xystage.xnum;
    ynum = obj.xystage.ynum; 
    wlnum = obj.laser.wlnum;  

    obj.plotdata.spectra_decay = ...
        reshape(obj.digitizer.spectra, [ynum, xnum, wlnum, ...
        factor, samples/factor]); 
    obj.plotdata.spectra_decay = mean(...
        obj.plotdata.spectra_decay, 4);
    obj.plotdata.spectra_decay = reshape(...
        obj.plotdata.spectra_decay, [ynum, xnum, wlnum, samples/factor]); 
    obj.plotdata.time_decay = ...
        0:(factor/sample_rate):((samples-1)/sample_rate);
    obj.plotdata.time_decay = round(obj.plotdata.time_decay, 9); 

end

