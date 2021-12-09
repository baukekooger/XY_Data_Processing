function [fitresult, gof] = fit_procedure_transmission(obj, ypos, xpos, ...
    active_area)
% Main fitting procedure for fitting transmission spectra using the
% Swanepoel method. This function can only be called after the single
% fitting has been done since certain parameters are set in the initial
% fitting.

    %% Define constants from initial fit
    x0 = obj.fitdata.optifit_data.xpoint;
    y0 = obj.fitdata.optifit_data.ypoint; 
    nsub = obj.fitdata.optifit_data.nsub; 
    ns_wl = obj.fitdata.optifit_data.ns_wl;  

    %% Define fitting functions 
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
        
    T = @(nsub, ns_wl, an, bn, ak, bk, ck, dk, ek, d, wl)( A(n1(nsub, ns_wl, wl), n1(an, bn, wl),...
        k1(ak, bk, ck, dk, ek, wl)) .* x(k1(ak, bk, ck, dk, ek, wl), wl, d) ./ ...
        ( B(n1(nsub, ns_wl, wl), n1(an, bn, wl), k1(ak, bk, ck, dk, ek, wl)) - ...
        C(n1(nsub, ns_wl, wl), n1(an, bn, wl), k1(ak, bk, ck, dk, ek, wl), d, wl) .* ...
        x(k1(ak, bk, ck, dk, ek, wl), wl, d) + ...
        D(n1(nsub, ns_wl, wl), n1(an, bn, wl), k1(ak, bk, ck, dk, ek, wl)) .* ...
        (x(k1(ak, bk, ck, dk, ek, wl), wl, d)).^2) );

    % Force real on transmission
    T_fit = @(an, bn, ak, bk, ck, dk, ek, d, x)real(T(nsub, ns_wl, an, bn, ak, bk, ck, dk, ek, d, x));

    % Prepare fitting data and set fitoptions. 
    wavelengths = obj.fitdata.optifit_data.wavelengths; 
    [~, idx] = intersect(obj.spectrometer.wavelengths, wavelengths);  
    transmission = ...
        squeeze(obj.plotdata.spectra_transmission(ypos, xpos, idx));
    [xData, yData] = prepareCurveData(wavelengths, transmission);
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.Robust = 'Bisquare';

%     try
%         fields = fieldnames(custom_fitoptions);
%     catch
%         fields = [];
%     end
%     for fii=1:length(fields)
%         f = fields{fii};
%         opts.(f) = custom_fitoptions.(f);
%     end
    
    % Get the fitting coefficients from good neighbouring fits 
    % to use as starting point. 
    coeffs = zeros(size(coeffvalues(obj.fitdata.fitobjects{y0, x0})));
    neighbors = 0;
    for dx=-1:1
        for dy=-1:1
            if abs(dx)==abs(dy) || ...
                (ypos+dy > size(active_area, 1)) || (ypos+dy < 1) || ... 
                (xpos+dx > size(active_area, 2)) || (xpos+dx < 1) 
                continue;
            end
            if active_area(ypos+dy, xpos+dx) == 0
                continue;
            end
            try
                gofboundary = min([0.99 * ...
                    obj.fitdata.goodnesses{ypos,xpos}.adjrsquare, ...
                    0.9]);
            catch
                gofboundary = nan;
            end
            if (obj.fitdata.goodnesses{ypos+dy, xpos+dx}.adjrsquare ...
                    >= gofboundary) || isnan(gofboundary)
                coeffs = coeffs + ...
                    coeffvalues(...
                    obj.fitdata.fitobjects{ypos+dy, xpos+dx});
            else
                continue;
            end
            neighbors = neighbors+1;
        end
    end
    if ~neighbors
        disp(['Minimal selection: ' num2str(gofboundary)]);
        disp(['This point: ' num2str(...
            obj.fitdata.goodnesses{ypos, xpos}.adjrsquare)]);
        throw(MException('XYEE:fittingerror',...
            sprintf(['Too few neighbors at (x,y)=(%d, %d) with ' ...
            'high gof to continue fit!'], xpos, ypos)));
    end
    coeffs = coeffs/neighbors;
    
    opts.StartPoint = coeffs;
    try
        % First try just altering the thickness. Not by much though
        % (250 nm)
        adjRSqMax = -Inf;
        opts.Lower = opts.StartPoint;
        opts.Upper = opts.StartPoint;
        dSearch = 250;
        dIterations  = 10;
        try
            if obj.fitdata.goodnesses{ypos, xpos}.adjrsquare > 0.99
                dSearch = 0;
                dIterations = 1;
            end
        catch
        end
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
        [fitresult, gof] = fit( xData, yData, T_fit, opts );
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