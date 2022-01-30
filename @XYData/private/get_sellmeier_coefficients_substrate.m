function [nsub_a, nsub_b, plotfigure] = get_sellmeier_coefficients_substrate(obj)
% Get the sellmeier a and b coefficients of the used substrate. 

    % Get the substrate type. 
    if contains(obj.substrate, 'borofloat' ,'IgnoreCase', true)
        substrate = 'borofloat'; 
    elseif contains(obj.substrate, 'quartz' ,'IgnoreCase', true)
        substrate = 'quartz'; 
    end

    % Read the optifit substrate fitting data. 
    switch substrate
        case 'borofloat'
            subdata = importdata('Borofloat_Data.dat'); 
        case 'quartz'
            subdata = importdata('Quartz_Data.dat'); 
    end
    
    wavelengths = subdata.data(:, 1); 
    refractive_index = subdata.data(:, 4); 
    wlmin = min(wavelengths);
    wlmax = max(wavelengths); 

    % load the fitting functions.
    fitfunctions = load("fitfunctions_transmission.mat"); 
   
    % set the fit options. 
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Lower = [0.5 100];
    opts.Upper = [2 400];
    opts.StartPoint = [1.6 185];
    [xData, yData] = prepareCurveData(wavelengths, refractive_index);
    opts.Exclude = excludedata(xData, yData, 'domain', [wlmin wlmax]);
    [fitresult, ~] = fit(xData, yData, fitfunctions.n1_real , opts);
    n_fit = [fitresult.a fitresult.b];
    opts.StartPoint = n_fit;
    [fitresult, ~] = fit(xData, yData, fitfunctions.n1 , opts);
    n_fit = [fitresult.a fitresult.b];
    
    
    plotfigure = subplot(2,2,1); 
    hold on 
    plot(wavelengths, refractive_index);
    plot(wavelengths, fitresult(wavelengths));
    legend({'Data', 'Fit'});
    title(['Refractive index fit for ' substrate]);
    xlabel('Wavelength');
    ylabel('Refractive index');
    hold off

    nsub_a = n_fit(1);
    nsub_b = n_fit(2);
end


