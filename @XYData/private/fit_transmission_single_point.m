function  fit_transmission_single_point(obj)
% Make an initial fit for the point that the optifit fitting was done on.
% This produces the sellmeier coefficients used for fitting all further
% points and provides a sanity check on the initial fit by making certain
% plots. 

    %% Get the substrate sellmeier coefficients.
    fig_subplots = figure; 
    [nsub, ns_wl, fitfigure] = get_sellmeier_coefficients_substrate(obj); 

    %% define the functions used for fitting. 
    alph    = @(k, wl)(4 * pi * k ./ wl);
    x       = @(k, wl, d)( exp(- alph(k, wl) .* d));
    phi     = @(n, d, wl)( 4 * pi .*n .* d ./ wl);
    
    A       = @(ns, n, k)(16 .* ns .* (n.^2 + k.^2));
    B       = @(ns, n, k)( ( (n+1).^2 + k.^2) .* (n+1).*(n+ns.^2) + k.^2);
    C       = @(ns, n, k, d, wl)( ( (n.^2 - 1 + k.^2) .* (n.^2 - ns.^2 + k.^2) ...
        - 2 * k.^2 .* (ns.^2 + 1) ) .* 2 .* cos(phi(n, d, wl)) ...
        - k.* ( 2 .* (n.^2 - ns.^2 + k.^2) + (ns.^2 + 1).*(n.^2 - 1 + k.^2)) ...
        .* 2 .* sin(phi(n, d, wl)));
    D       = @(ns, n, k)( ((n-1).^2 + k.^2) .* ( (n-1).*(n-ns.^2) + k.^2) );
    
    % Sellmeier equation
    n1 = @(a, b, x)( sqrt( 1 + a .* x.^2 ./ (x.^2 - b.^2)) );
    n1_real = @(a, b, x)( real(sqrt( 1 + a .* x.^2 ./ (x.^2 - b.^2))) );
    % Band gap-included Taylor expansion dispersion relation
    % All factors of the BG-term have a lower limit of 0
    % Others are free
    k1 = @(a, b, c, d, e, x)( 1240*a .* x  .* (1./x - 1./b).^2 .* heaviside(b-x) ...
            + c + d./x + e./x.^2 );
        
    T = @(nsub, ns_wl, an, bn, ak, bk, ck, dk, ek, d, wl)(A(n1(nsub, ns_wl, wl), n1(an, bn, wl),...
        k1(ak, bk, ck, dk, ek, wl)) .* x(k1(ak, bk, ck, dk, ek, wl), wl, d) ./ ...
        ( B(n1(nsub, ns_wl, wl), n1(an, bn, wl), k1(ak, bk, ck, dk, ek, wl)) - ...
        C(n1(nsub, ns_wl, wl), n1(an, bn, wl), k1(ak, bk, ck, dk, ek, wl), d, wl) .* ...
        x(k1(ak, bk, ck, dk, ek, wl), wl, d) + ...
        D(n1(nsub, ns_wl, wl), n1(an, bn, wl), k1(ak, bk, ck, dk, ek, wl)) .* ...
        (x(k1(ak, bk, ck, dk, ek, wl), wl, d)).^2));
    
    % Force "Real" on Transmission
    T_fit = @(an, bn, ak, bk, ck, dk, ek, d, x)real(T(nsub, ns_wl, an, bn, ak, bk, ck, dk, ek, d, x));

    %% Refit input data for intial guess of d, n and k
    wavelengths = obj.fitdata.optifit_data.wavelengths; 
    wlmin = min(wavelengths);
    wlmax = max(wavelengths); 
    
    refractive_index = obj.fitdata.optifit_data.refractive_index; 
    extinction_coefficient = ...
        obj.fitdata.optifit_data.extinction_coefficient; 
    thickness = str2double(obj.fitdata.optifit_data.fitparams.Thickness); 
    
    transmission = obj.fitdata.optifit_data.transmission_experimental./100;

    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Lower = [0.5 100];
    opts.Upper = [2 400];
    opts.StartPoint = [1.6 185];
    [xData, yData] = prepareCurveData(wavelengths, refractive_index);
    opts.Exclude = excludedata(xData, yData, 'domain', [wlmin wlmax]);
    [fitresult, ~] = fit(xData, yData, n1_real , opts);
    guess_n = [fitresult.a fitresult.b];
    opts.StartPoint = guess_n;
    [fitresult, ~] = fit(xData, yData, n1 , opts);
    guess_n = [fitresult.a fitresult.b];

    subplot(2,2,2);
    plot(wavelengths, refractive_index, 'b-');
    hold on;
    plot(wavelengths, fitresult(wavelengths), ...
        'k--', xData, yData, '.');
    title('refractive index fit film');
    
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Lower = [0 0 0 -Inf -Inf];
    opts.StartPoint = [1 430 1 1 1];
    [xData, yData] = prepareCurveData(wavelengths, extinction_coefficient);
    [fitresult, ~] = fit(xData, yData, k1 , opts);
    guess_k = ...
        [fitresult.a fitresult.b fitresult.c fitresult.d fitresult.e];

    subplot(2,2,3); 
    plot(wavelengths, extinction_coefficient, 'b-');
    hold all;
    plot(wavelengths, fitresult(wavelengths), ...
        'k--', xData, yData, '.');
    title('fit extinction coefficient film');

    subplot(2, 2, 4)
    hold all; 
    plot(wavelengths, transmission)
    plot(wavelengths, T(nsub, ns_wl, guess_n(1), guess_n(2), ...
        guess_k(1), guess_k(2), guess_k(3), guess_k(4), ...
        guess_k(5), thickness, wavelengths))
    legend({'Transmission data', 'Fitdata'})
    title('Transmission data and optifit fitdata.')

    [fitresult, gof, output] =  refit_optifit([guess_n, guess_k, thickness]);
    subplot(2, 2, 4)
    hold on
    plot(wavelengths, fitresult(wavelengths))
    legend({'Transmission data', 'Fit from optifit', 'Fit one pass'})
    hold off

    xpoint = obj.fitdata.optifit_data.xpoint; 
    ypoint = obj.fitdata.optifit_data.ypoint; 
    obj.fitdata.fitobjects{ypoint, xpoint} = fitresult; 
    obj.fitdata.goodnesses{ypoint, xpoint} = gof;
    obj.fitdata.outputs{ypoint, xpoint} = output; 
    obj.fitdata.optifit_data.nsub = nsub;
    obj.fitdata.optifit_data.ns_wl = ns_wl; 

    %% Helper functions   
    function [fitresult, gof, output] = refit_optifit(coeffs)
        [xData, yData] = prepareCurveData(wavelengths, transmission);
        opts = fitoptions('Method', 'NonlinearLeastSquares');
        opts.Display = 'Off';
        opts.Robust = 'Bisquare';
        opts.StartPoint = coeffs;
        try
            % First try just altering the thickness. Not by much though
            % (250 nm)
            adjRSqMax = -Inf;
            opts.Lower = opts.StartPoint;
            opts.Upper = opts.StartPoint;
            dSearch = 250;
            dIterations  = 10;
            tSearch = linspace(opts.StartPoint(8)-dSearch,...
                opts.StartPoint(8)+dSearch, dIterations);
            for tii = 1:length(tSearch)
                opts.StartPoint(8) = tSearch(tii);
                opts.Lower(8) = tSearch(tii) - 50;
                opts.Upper(8) = tSearch(tii) + 50;
                [tFitresult, gof] = fit(xData, yData, T_fit, opts);
                if gof.adjrsquare > adjRSqMax
                    fitresult = tFitresult;
                    adjRSqMax = gof.adjrsquare;
                end
            end
            % Then the absorption coeffients
            opts.StartPoint = coeffvalues(fitresult);
            opts.Lower = opts.StartPoint;
            opts.Upper = opts.StartPoint;
            opts.Lower(3:5) = min([opts.Lower(3:5) * 0.5 - 3;...
                opts.Upper(3:5) * 1.5 + 3]);
            opts.Lower(4) = max([opts.Lower(4), 1]);
            opts.Upper(3:5) = max([opts.Upper(3:5) * 0.5 - 3;...
                opts.Upper(3:5) * 1.5 + 3]);
            [fitresult, ~] = fit( xData, yData, T_fit, opts );
            % Then the index of refraction
            opts.StartPoint = coeffvalues(fitresult);
            opts.Lower = opts.StartPoint;
            opts.Upper = opts.StartPoint;
            opts.Lower(1:2) = min([opts.Lower(1:2) * 0.5 - 3;
                opts.Upper(1:2) * 1.5 + 3]);
            opts.Lower(1) = max([opts.Lower(1), 0]);
            opts.Lower(2) = max([opts.Lower(2), 1]);
            opts.Upper(1:2) = max([opts.Upper(1:2) * 0.5 - 3;
                opts.Upper(1:2) * 1.5 + 3]);
            [fitresult, ~] = fit( xData, yData, T_fit, opts );
            % Then a free fit based on what we have up until now
            opts.StartPoint = coeffvalues(fitresult);
            opts.Lower = min([opts.StartPoint * 0.5 - 3;...
                opts.StartPoint * 1.5 + 3]);
            opts.Upper = max([opts.StartPoint * 0.5 - 3;...
                opts.StartPoint * 1.5 + 3]);
            opts.Lower(1) = max([opts.Lower(1), 0]);
            opts.Lower(2) = max([opts.Lower(2), 1]);
            opts.Lower(4) = max([opts.Lower(4), 1]);
            [fitresult, gof, output] = fit(xData, yData, T_fit, opts);
        catch e
            disp(e.message)
            a.sse = Inf;
            a.rsquare = -Inf;
            a.dfe = Inf;
            a.adjrsquare = -Inf;
            a.rmse = Inf;
            gof = a;
            sp = arrayfun(@(x)x, opts.StartPoint, 'UniformOutput', false);
            fitresult = cfit(fittype(T_fit), ...
                sp{:});
        end
    end
end
%     try
%         fields = fieldnames(custom_fitoptions);
%     catch
%         fields = [];
%     end
%     for fii=1:length(fields)
%         f = fields{fii};
%         opts.(f) = custom_fitoptions.(f);
%     end
%     if (nargin<4 || isempty(coeffs))
%         coeffs = zeros(size(coeffvalues(fitresults{x0,y0})));
%         neighbors = 0;
%         for dx=-1:1
%             for dy=-1:1
%                 if abs(dx)==abs(dy) || ...
%                         (x+dx > size(active_area,1)) || ...
%                         (x+dx < 1) || ...
%                         (y+dy > size(active_area, 2)) || ...
%                         (y+dy < 1)
%                     continue;
%                 end
%                 if active_area(x+dx, y+dy)==0
%                     continue;
%                 end
%                 try
%                     gofboundary = min([0.99 * gofs{x,y}.adjrsquare, 0.9]);
%                 catch
%                     gofboundary = nan;
%                 end
%                 if (gofs{x+dx, y+dy}.adjrsquare >= gofboundary) || isnan(gofboundary)
%                     coeffs = coeffs + coeffvalues(fitresults{x+dx, y+dy});
%                 else
%                     continue;
%                 end
%                 neighbors = neighbors+1;
%             end
%         end
%         if ~neighbors
%             disp(['Minimal selection: ' num2str(gofboundary)]);
%             disp(['This point: ' num2str(gofs{x,y}.adjrsquare)]);
%             throw(MException('XYEE:fittingerror',...
%                 sprintf('Too few neighbors at (x,y)=(%d, %d) with high gof to continue fit!', ...
%                 x, y)));
%         end
%         coeffs = coeffs/neighbors;
%     end
