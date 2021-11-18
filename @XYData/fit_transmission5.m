function XYEEobj = fit_transmission5(XYEEobj, varargin)
%FIT_TRANSMISSION fits XY transmission spectra to a predefined seed-transmission at x0,y0
% INPUT
% 1. XYEEobj: An "XYEE object" (struct), minimally formatted as following:
%   XYEEobj.spectrum - Spectrum matrix as
%       spectrum( x number, y number, transmission) valued 0 to 1
%   XYEEobj.em_wl - Vector with the wavelengths (in nm) of the transmission
% 2. Data: Usually an OPTIFIT table with the initial fitting data, but can be
%          anything formatted as:
%           - Data.Wavelengthnm (Wavelengths decribed in nm)
%           - Data.Refractive_index (Refractive index vector)
%           - Data.Extintion_coefficient (Extinction coefficient vector,
%                       Pay mind that there is no "c" in "Extinction", this is a 
%                       remnant of using OPTIFIT)
% 3. x0: x-index where the initial fitting started
% 4. y0: y-index where the initial fitting started
% 5. nsub: 'a' value of index of refraction of the substrate
% 6. ns_wl: 'b' value of the index of refraction of the substrate
% 7. d0: Initial guess of the thickness
% 8. passes: Desired amount of repeats to the fitting
% OPTIONAL
% 9. wlmin: minimum wavelength (in nm) to start fitting; else set to 310 nm
% 10. wlmax: maximum wavelength (in nm) to end fitting; else set to 850 nm
% OPTIONAL ARGUMENTS
% - 'continue' or 'c', with as next argument a boolean to indicate if the
%       XYEEobj already has fitted data and which should be used as input
% - 'custom_fitoptions', 'cfopt', 'fitopts', with as next arguments a struct
%           with custom fitoptions formatted as a MATLAB fitoptions struct
% - 'topval', with as next argument the percentage of highest adj.-R^2 data 
%               that should be used as seeds for the next fitting pass
%
% RETURNS
%   The input XYEEobj, with added:
%   XYEEobj.fitdata.fitresult
%       A cell filled with MATLAB fitobjs with the results of the fitting.
%       Sized {x number, y number}
%   XYEEobj.fitdata.gof 
%       A cell filled with MATLAB goodness of fit indicators for each
%       fitting in XYEEobj.fitdata.fitresult
%
% AUTHOR
% Evert Merkx
% E-MAIL
% e.p.j.merkx at tudelft.nl
% LAST REVISION
% 15-08-2018
%
%
    

%% Setup varargin
varargin = cellflat(varargin);
Data = varargin{1};
x0 = varargin{2};
y0 = varargin{3};
nsub = varargin{4};
ns_wl = varargin{5};
d0 = varargin{6};
passes = varargin{7};
vararginstart = 8;
try
    wlmin = varargin{8};
    wlmax = varargin{9};
    vararginstart = 10;
catch
    wlmin = 310;
    wlmax = 850;
end


skip_first = false;
custom_fitoptions = [];
topval = 0.1;
for ii=vararginstart:2:length(varargin)
    switch varargin{ii}
        case {'continue', 'c'}
            % Continue where previous fit left off
            skip_first = varargin{ii+1};
        case {'custom_fitoptions', 'cfopt', 'fitopts'}
            custom_fitoptions = varargin{ii+1};
        case {'topval', 'tv'}
            topval = varargin{ii+1};
    end
end

progressbar('Total progress', 'Initial fitting', 'Detailed fitting');
total_progress = size(XYEEobj.spectrum,1)*size(XYEEobj.spectrum,2)*(passes+1);
current_progress = 0;

%% General functions
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

% Force "Real" on Transmission
inclWl  = (XYEEobj.em_wl>wlmin) & (XYEEobj.em_wl<wlmax);
wl      = XYEEobj.em_wl(inclWl);
T_fit = @(an, bn, ak, bk, ck, dk, ek, d, x)real(T(nsub, ns_wl, an, bn, ak, bk, ck, dk, ek, d, x));

%% Initialize data storage
fitresults = cell(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));
gofs = cell(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));

if skip_first
    fitresults = XYEEobj.fitdata.fitresult;
    gofs = XYEEobj.fitdata.gof;
else
    %% Refit input data for intial guess of d, n and k
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Lower = [0.5 100];
    opts.Upper = [2 400];
    opts.StartPoint = [1.6 185];
    [xData, yData] = prepareCurveData(Data.Wavelengthnm, Data.Refractive_index);
    opts.Exclude = excludedata(xData, yData, 'domain', [wlmin wlmax]);
    [fitresult, ~] = fit(xData, yData, n1_real , opts);
    guess_n = [fitresult.a fitresult.b];
    opts.StartPoint = guess_n;
    [fitresult, ~] = fit(xData, yData, n1 , opts);
    guess_n = [fitresult.a fitresult.b];

    figure; 
    subplot(2,1,1);
    plot(Data.Wavelengthnm, Data.Refractive_index, 'b-');
    hold all;
    plot(Data.Wavelengthnm, fitresult(Data.Wavelengthnm), ...
        'k--', xData, yData, '.');
    title('n');
    
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Lower = [0 0 0 -Inf -Inf];
    opts.StartPoint = [1 430 1 1 1];
    [xData, yData] = prepareCurveData(Data.Wavelengthnm, Data.Extintion_coefficient);
    [fitresult, ~] = fit(xData, yData, k1 , opts);
    guess_k = [fitresult.a fitresult.b fitresult.c fitresult.d fitresult.e];
    transmission = squeeze(XYEEobj.spectrum(x0,y0,inclWl));

    subplot(2,1,2); 
    plot(Data.Wavelengthnm, Data.Extintion_coefficient, 'b-');
    hold all;
    plot(Data.Wavelengthnm, fitresult(Data.Wavelengthnm), ...
        'k--', xData, yData, '.');
    title('k');
    
    [fitresult, gof] =  produce_fit( x0, y0, 0, [guess_n, guess_k, d0] );
    fitresults{x0, y0} = fitresult;
    figure; plot(wl, squeeze(XYEEobj.spectrum(x0,y0,inclWl)), wl, fitresult(wl));
    gofs{x0, y0} = gof;
    
    [xinx, yinx] = meshgrid(1:size(XYEEobj.spectrum,1), 1:size(XYEEobj.spectrum,2));
    xinx = xinx';
    yinx = yinx';
    % Fill downwards
    total = size(XYEEobj.spectrum,1)*size(XYEEobj.spectrum,2);
    fitted = 1;
    for ii= (y0+1):size(XYEEobj.spectrum,2)
%         fprintf('y=%d\n',ii);
        active_area = ((xinx == x0) & (yinx == ii-1));
        [fitresult, gof] = produce_fit(x0,ii,active_area);
        fitresults{x0, ii} = fitresult;
        gofs{x0, ii} = gof;
        fitted = fitted + 1;
        current_progress = current_progress+1;
        progressbar(current_progress/total_progress, fitted/total);
    end    
    % Fill upwards
    for ii= (y0-1):-1:1
%         fprintf('y=%d\n',ii);
        active_area = (xinx == x0) & (yinx == ii+1);
        [fitresult, gof] = produce_fit(x0,ii,active_area);
        fitresults{x0, ii} = fitresult;
        gofs{x0, ii} = gof;
        fitted = fitted + 1;
        current_progress = current_progress+1;
        progressbar(current_progress/total_progress, fitted/total);
    end

    for ii=1:size(XYEEobj.spectrum,2)
        % Fill to the right
        for jj=(x0+1):size(XYEEobj.spectrum,1)
%             fprintf('x,y=%d,%d\n',jj,ii);
            active_area = (xinx == jj-1) & (yinx == ii);
            [fitresult, gof] = produce_fit(jj,ii,active_area);
            fitresults{jj, ii} = fitresult;
            gofs{jj, ii} = gof;
            fitted = fitted + 1;
            current_progress = current_progress+1;
            progressbar(current_progress/total_progress, fitted/total);
        end
        % Fill to the left
        for jj=(x0-1):-1:1
%             fprintf('x,y=%d,%d\n',jj,ii);
            active_area = (xinx == jj+1) & (yinx == ii);
            [fitresult, gof] = produce_fit(jj,ii,active_area);
            fitresults{jj, ii} = fitresult;
            gofs{jj, ii} = gof;
            fitted = fitted + 1;
            current_progress = current_progress+1;
            progressbar(current_progress/total_progress, fitted/total);
        end
    end
end

% Store intermediate fittings
TEMP_FILES = cell(length(passes+1),1);
FITFILENAME = sprintf('%s_TEMP_TFIT_PASS_%03d.mat', datestr(datetime('now'), 'yymmddHHMMSS'), 0);
TEMP_FILES{1} = FITFILENAME;
save(FITFILENAME, 'fitresults', 'gofs');
    
    %% Higher order passes, fit using surrounding data and choosing the best
    if passes>0
        h = figure;
        h2 = figure;
    end
    for ii=1:passes
        % Final pass has a "True" T. Other passes use a forced "Real"
        % compontent, as MATLAB terminates a fit when the outcome turns
        % imaginary.
        if ii==passes
            T_fit =  @(an, bn, ak, bk, ck, dk, ek, d, x)T(nsub, ns_wl, ...
                an, bn, ak, bk, ck, dk, ek, d, x);
        end
        fprintf('Pass %d/%d\n',ii,passes);
        rsq = cellfun(@(x)(x.adjrsquare),gofs);
        
        % Display these fits' R^2
        figure(h);
        subplot(1,passes,ii);
        imagesc(rsq);
        caxis([0.98 1]);
        
        % Use the top 10% to fit the rest
        rsq_lin = sort(reshape(rsq, [1 numel(rsq)]));
        fitindex = double(rsq > rsq_lin(round((1 - topval)*numel(rsq))) );
        if sum(reshape(fitindex, [1 numel(fitindex)])) < 1
            disp('Too low Q fit for multiple passes to continue!');
            return
        end
        
        n = 2;
        while find(fitindex==0,1)
            selected_rsq = double(fitindex>0);
            expanded_rsq = conv2(fitindex, [0 1 0; 1 1 1; 0 1 0], 'same');
            expanded_rsq = (double(expanded_rsq>0) - selected_rsq)*n;
            fitindex = fitindex + expanded_rsq;
            n = n+1;
        end
        
        figure(h2);
        subplot(1,passes,ii);
        imagesc(fitindex);
        
        gof_set = cell([1, 3]);
        fit_set = cell([1, 3]);
        total = sum(sum(double(fitindex>1)));
        progress=0;
        total_progress = size(XYEEobj.spectrum,1)*size(XYEEobj.spectrum,2)*(passes+1);
        current_progress = size(XYEEobj.spectrum,1)*size(XYEEobj.spectrum,2)*(ii);
        for jj=2:max(reshape(fitindex, [1 numel(fitindex)]))
            indices = find(fitindex==jj);
            for inx=reshape(indices, [1 size(indices)])
                [I,J] = ind2sub(size(fitindex), inx);
                gof_set{1} = gofs{I,J};
                fit_set{1} = fitresults{I,J};
                try
                    [fit_set{2}, gof_set{2}] = produce_fit(I,J,fitindex<=jj);
                catch e
                    disp(e.message);
                    fprintf('Error at x=%d, y=%d\n', I, J);
                    gof_set{2}.adjrsquare = -Inf;
                end
                try
                    [fit_set{3}, gof_set{3}] = produce_fit(I,J,fitindex>-1);
                catch
                    gof_set{3}.adjrsquare = -Inf;
                end

                rsq = cellfun(@(x)(x.adjrsquare),gof_set);
                [~, argmax] = max(rsq);
                fitresults{I, J} = fit_set{argmax};
                gofs{I,J} = gof_set{argmax};
                progress = progress+1;
                current_progress = current_progress + 1;
                progressbar(current_progress/total_progress , 1, progress/total);
            end
%             fprintf('%s: Pass %d, progress: %.2f %%\n',datestr(now),ii,progress*100/total);
        end
    FITFILENAME = sprintf('%s_TEMP_TFIT_PASS_%03d.mat', ...
        datestr(datetime('now'), 'yymmddHHMMSS'), ii);
    TEMP_FILES{ii+1} = FITFILENAME;
    save(FITFILENAME, 'fitresults', 'gofs');
    end
    progressbar(1);
    
    %% Return XYEEobj
    XYEEobj.fitdata.fitresult = fitresults;
    XYEEobj.fitdata.gof = gofs;
    
    % Remove temporary clutter
    for ii=1:length(TEMP_FILES)
        delete(TEMP_FILES{ii});
    end
    
    %% Helper functions   
    function [fitresult, gof] = produce_fit(x,y,active_area, coeffs)
        transmission = squeeze(XYEEobj.spectrum(x,y,inclWl));
        [xData, yData] = prepareCurveData( wl, transmission );
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.Robust = 'Bisquare';
        try
            fields = fieldnames(custom_fitoptions);
        catch
            fields = [];
        end
        for fii=1:length(fields)
            f = fields{fii};
            opts.(f) = custom_fitoptions.(f);
        end
        if (nargin<4 || isempty(coeffs))
            coeffs = zeros(size(coeffvalues(fitresults{x0,y0})));
            neighbors = 0;
            for dx=-1:1
                for dy=-1:1
                    if abs(dx)==abs(dy) || ...
                            (x+dx > size(active_area,1)) || ...
                            (x+dx < 1) || ...
                            (y+dy > size(active_area, 2)) || ...
                            (y+dy < 1)
                        continue;
                    end
                    if active_area(x+dx, y+dy)==0
                        continue;
                    end
                    try
                        gofboundary = min([0.99 * gofs{x,y}.adjrsquare, 0.9]);
                    catch
                        gofboundary = nan;
                    end
                    if (gofs{x+dx, y+dy}.adjrsquare >= gofboundary) || isnan(gofboundary)
                        coeffs = coeffs + coeffvalues(fitresults{x+dx, y+dy});
                    else
                        continue;
                    end
                    neighbors = neighbors+1;
                end
            end
            if ~neighbors
                disp(['Minimal selection: ' num2str(gofboundary)]);
                disp(['This point: ' num2str(gofs{x,y}.adjrsquare)]);
                throw(MException('XYEE:fittingerror',...
                    sprintf('Too few neighbors at (x,y)=(%d, %d) with high gof to continue fit!', ...
                    x, y)));
            end
            coeffs = coeffs/neighbors;
        end
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
                if gofs{x,y}.adjrsquare > 0.99
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
                [tFitresult, gof] = fit( xData, yData, T_fit, opts );
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
end