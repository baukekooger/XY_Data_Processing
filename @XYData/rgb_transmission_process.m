function obj = rgb_transmission_process(obj)
% Makes transmission spectrum and integrates transmission spectrum to
% provide visual (rgb) value for datapicker plot. This plot is the same,
% also when raw data or remove dark is selected in the UI. 
% Nan and inf values are replaced by zeros and first and last 50 values are
% discarded because they can be noisy 
    darkrepeat = repmat(obj.spectrometer.darkspectrum, 1, ...
        obj.xystage.xnum, obj.xystage.ynum);
    darkrepeat = permute(darkrepeat, [2 3 1]); 

    lamprepeat = repmat(obj.spectrometer.lampspectrum, 1, ...
        obj.xystage.xnum, obj.xystage.ynum);
    lamprepeat = permute(lamprepeat, [2 3 1]);
    spectra = obj.spectrometer.spectra - darkrepeat; 
    spectra = spectra ./ lamprepeat;
    spectra = shiftdim(spectra, 2); 
    spectra(isnan(spectra)) = 0;
    spectra(isinf(spectra)) = 0;

    rgb = squeeze(trapz(spectra(50:end-50,:,:)));
    obj.plotdata.rgb = rgb;
 
end

