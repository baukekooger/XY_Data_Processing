function [ obj ] = rgb_transmission_process( obj )
% integrates each spectrum to produce a scalar as an indicator for the rgb
% plot
% nan and inf values are replaced by zeros and first and last 50 values are
% discarded because they can be noisy 

    spectra = shiftdim(obj.XYEEobj.spectrometer.spectra, 2); 
    spectra(isnan(spectra)) = 0;
    spectra(isinf(spectra)) = 0;

    rgb = squeeze(trapz(spectra(50:end-50,:,:)));
    obj.rgb = rgb;

end

