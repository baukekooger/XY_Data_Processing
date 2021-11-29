function XYEEobj = fit_transmission4(XYEEobj, varargin)
%FIT_TRANSMISSION fits XY transmission spectra to a predefined seed-transmission at x0,y0
% Uses a Drude-Lorentz description for the transmission

%% Setup varargin
varargin = cellflat(varargin);
Data = varargin{1};
x0 = varargin{2};
y0 = varargin{3};
nsub = varargin{4};
d0 = varargin{5};
passes = varargin{6};
try
    wlmin = varargin{7};
    wlmax = varargin{8};
catch
    wlmin = 350;
    wlmax = 830;
end

%% General functions
    alph    = @(k, wl)(4 * pi * k ./ wl);
    xv       = @(k, wl, d)( exp(- alph(k, wl) .* d));
    phi     = @(n, d, wl)( 4 * pi .*n .* d ./ wl);

    A       = @(ns, n, k)(16 * ns * (n.^2 + k.^2));
    B       = @(ns, n, k)( ( (n+1).^2 + k.^2) .* (n+1).*(n+ns.^2) + k.^2);
    C       = @(ns, n, k, d, wl)( ( (n.^2 - 1 + k.^2) .* (n.^2 - ns.^2 + k.^2) ...
        - 2 * k.^2 .* (ns.^2 + 1) ) .* 2 .* cos(phi(n, d, wl)) ...
        - k.* ( 2 .* (n.^2 - ns.^2 + k.^2) + (ns.^2 + 1).*(n.^2 - 1 + k.^2)) ...
        .* 2 .* sin(phi(n, d, wl)));
    D       = @(ns, n, k)( ((n-1).^2 + k.^2) .* ( (n-1).*(n-ns.^2) + k.^2) );
    
    er_p = @(e_inf, wp, w0, G, w)(e_inf + wp.^2.*(w0.^2 - w.^2)./ ...
        ( (w0.^2-w.^2).^2 + (w.*G).^2 ) );
    er_pp = @(wp, w0, G, w)(wp.^2.*(w.*G)./ ...
        ( (w0.^2-w.^2).^2 + (w.*G).^2 ) );
    
    n1 = @(e_inf, wp, w0, G, x)real(sqrt(er_p(e_inf, wp, w0, G, x) + ...
        1i.*er_pp(wp, w0, G, x) ));
    k1 = @(e_inf, wp, w0, G, x)imag(sqrt(er_p(e_inf, wp, w0, G, x) + ...
        1i.*er_pp(wp, w0, G, x) ));

%     % Sellmeier equation
%     n1 = @(a, b, c, x)( sqrt( a + b .* x.^2 ./ (x.^2 - c.^2)) );
%     % Band gap-included Taylor expansion dispersion relation
%     % All factors of the BG-term have a lower limit of 0
%     % Others are free
%     k1 = @(a, b, c, d, e, x)( 1240*a .* x  .* (1./x - 1./b).^2 .* heaviside(b-x) ...
%             + c + d./x + e./x.^2 );

    T = @(ns, e_inf, wp, w0, G, d, x)( A(ns, n1(e_inf, wp, w0, G, x),...
        k1(e_inf, wp, w0, G, x)) .* xv(k1(e_inf, wp, w0, G, x), x, d) ./ ...
        ( B(ns, n1(e_inf, wp, w0, G, x), k1(e_inf, wp, w0, G, x)) - ...
        C(ns, n1(e_inf, wp, w0, G, x), k1(e_inf, wp, w0, G, x), d, x) .* ...
        xv(k1(e_inf, wp, w0, G, x), x, d) + ...
        D(ns, n1(e_inf, wp, w0, G, x), k1(e_inf, wp, w0, G, x)) .* ...
        (xv(k1(e_inf, wp, w0, G, x), x, d)).^2) );
    
    %% Initialize data storage
    fitresults = cell(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));
    gofs = cell(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));

    %% Apply Envelope method for intial guess of d, n and k
    inclWl = (Data.Wavelengthnm>wlmin) & (Data.Wavelengthnm<wlmax);
    wl = Data.Wavelengthnm(inclWl);
    % Convert and normalize wavelengths to not get into trouble with 
    % floating point errors
    wl = 299792458*1e9./wl;
    wl = wl/1e12;
%     mwl = max(wl);
%     wl = wl./mwl;
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Robust = 'Bisquare';
    opts.Lower = [0 0 0 0].*10;
    opts.Upper = [10 5e3 5e3 1e4];
    opts.StartPoint = [1 1000 1000 10];
    [xData, yData] = prepareCurveData(wl, Data.Refractive_index(inclWl));
    [fitresult, ~] = fit(xData, yData, n1 , opts);
    guess_n = coeffvalues(fitresult);

    figure; 
    subplot(2,1,1);
    plot(xData, yData, 'g-');
    hold all;
    plot(wl, fitresult(wl), 'k--');
    title('n');
    
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Lower = [0 0 0 0].*10;
    opts.Upper = [10 5e3 5e3 1e4];
    opts.StartPoint = [1 1000 1000 10];
    [xData, yData] = prepareCurveData(wl, Data.Extintion_coefficient(inclWl));
    [fitresult, ~] = fit(xData, yData, k1 , opts);
    guess_k = coeffvalues(fitresult);
    transmission = squeeze(XYEEobj.spectrum(x0,y0,inclWl));

    subplot(2,1,2); 
    plot(xData, yData, 'b-');
    hold all;
    plot(wl, fitresult(wl), ...
        'k--', xData, yData, '.');
    title('k');
    
    guess_n
    guess_k
    guess_dl = (guess_n + guess_k)/2

    guess_dl = [0.6657 26.07 648.2 113];

    T_fit = @(e_inf, wp, w0, G, d, x)T(nsub, e_inf, wp, w0, G, d, x);
    [fitresult, gof] =  produce_fit( x0, y0, 0, [guess_dl, d0] );
    fitresults{x0, y0} = fitresult;
    gofs{x0, y0} = gof;
    
%     %% Figure!
    figure;
    plot(wl, squeeze(XYEEobj.spectrum(x0,y0,inclWl)));
    hold all;
    plot(fitresult);
    
    fitresult
    
    return
    
%     nrefr = ones(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2)) * -100;
%     nrefr(x0,y0) = n1(fitresult.an, fitresult.bn, fitresult.cn, 632);
    
    fitindex = zeros(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));
    fitindex(x0,y0) = 1;
    n = 2;
    while find(fitindex==0,1)
        selected_rsq = double(fitindex>0);
        expanded_rsq = conv2(fitindex, [0 1 0; 1 1 1; 0 1 0], 'same');
        expanded_rsq = (double(expanded_rsq>0) - selected_rsq)*n;
        fitindex = fitindex + expanded_rsq;
        n = n+1;
    end
%     fitindex = fitindex';
%     save('images/fitindices.mat', 'fitindex');
%     nrefr = nrefr';
%     save('images/nrefr.mat', 'nrefr');
    
    %% First pass, fill using a seedfit    
try
    load('fitresults4.mat');
catch
    [yinx, xinx] = meshgrid(1:size(XYEEobj.spectrum,1), 1:size(XYEEobj.spectrum,2));
    % Fill downwards
    for ii= (y0+1):size(XYEEobj.spectrum,2)
        fprintf('y=%d\n',ii);
        active_area = ((xinx == x0) & (yinx == ii-1));
        [fitresult, gof] = produce_fit(x0,ii,active_area);
        fitresults{x0, ii} = fitresult;
        gofs{x0, ii} = gof;
        disp(gof.adjrsquare);
    end    
    % Fill upwards
    for ii= (y0-1):-1:1
        fprintf('y=%d\n',ii);
        active_area = (xinx == x0) & (yinx == ii+1);
        [fitresult, gof] = produce_fit(x0,ii,active_area);
        fitresults{x0, ii} = fitresult;
        gofs{x0, ii} = gof;
    end
    
    for ii=1:size(XYEEobj.spectrum,2)
        % Fill to the right
        for jj=(x0+1):size(XYEEobj.spectrum,1)
            fprintf('x,y=%d,%d\n',jj,ii);
            active_area = (xinx == jj-1) & (yinx == ii);
            [fitresult, gof] = produce_fit(jj,ii,active_area);
            fitresults{jj, ii} = fitresult;
            gofs{jj, ii} = gof;
        end
        % Fill to the left
        for jj=(x0-1):-1:1
            fprintf('x,y=%d,%d\n',jj,ii);
            active_area = (xinx == jj+1) & (yinx == ii);
            [fitresult, gof] = produce_fit(jj,ii,active_area);
            fitresults{jj, ii} = fitresult;
            gofs{jj, ii} = gof;
        end
    end
save('fitresults4.mat','fitresults', 'gofs');
end
% 
% nrefr = cellfun(@(x)(n1(x.an, x.bn, x.cn, 632)), fitresults);
% nrefr = nrefr';
% aRsq = cellfun(@(x)(x.adjrsquare), gofs);
% aRsq = aRsq';
% 
% save('images/seedfit_results.mat', 'nrefr', 'aRsq');
    
    %% Higher order passes, fit using surrounding data and choosing the best
    if passes>0
        h = figure;
        h2 = figure;
    end
    for ii=1:passes
        fprintf('Pass %d/%d\n',ii,passes);
        rsq = cellfun(@(x)(x.adjrsquare),gofs);
        
        % Display these fits' R^2
        figure(h);
        subplot(1,passes,ii);
        imagesc(rsq);
        caxis([0.98 1]);
        
        % Use the top 10% to fit the rest
        rsq_lin = sort(reshape(rsq, [1 numel(rsq)]));
        fitindex = double(rsq > rsq_lin(round(0.9*numel(rsq))) );
        if sum(reshape(fitindex, [1 numel(fitindex)])) < 1
            disp('Too low Q fit for multiple passes to continue!');
            return
        end
        
%         fitindex = double(rsq>0.99);
%         if sum(reshape(fitindex, [1 numel(fitindex)])) < 1
%             disp('Too low Q fit for multiple passes to continue!');
%             return
%         end
        
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
        
%         finx = fitindex';
%         save('images/first_pass_fitindex', 'finx');
%         return;
        
        gof_set = cell([1, 3]);
        fit_set = cell([1, 3]);
        total = sum(sum(double(fitindex>1)));
        progress=0;
        for jj=2:max(reshape(fitindex, [1 numel(fitindex)]))
            indices = find(fitindex==jj);
            for inx=reshape(indices, [1 size(indices)])
                [I,J] = ind2sub(size(fitindex), inx);
                gof_set{1} = gofs{I,J};
                fit_set{1} = fitresults{I,J};
                try
                    [fit_set{2}, gof_set{2}] = produce_fit(I,J,fitindex<=jj);
                catch
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
            end
            fprintf('%s: Pass %d, progress: %.2f %%\n',datestr(now),ii,progress*100/total);
        end
    end
    
    %% Return XYEEobj
    XYEEobj.fitdata.fitresult = fitresults;
    XYEEobj.fitdata.gof = gofs;
    
    %% Helper functions   
    function [fitresult, gof] = produce_fit(x,y,active_area, coeffs)
        transmission = squeeze(XYEEobj.spectrum(x,y,inclWl));
        [xData, yData] = prepareCurveData( wl, transmission );
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'final';
        opts.Robust = 'Bisquare';
        opts.TolFun = 1e-12;
        opts.TolX = 1e-12;
        opts.MaxFunEvals = 5e3;
        opts.MaxIter = 5e3;
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
                        gofboundary = 0.99 * gofs{x,y}.adjrsquare;
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
                disp(coeffs);
                disp(gofboundary);
                disp(gofs{x+dx, y+dy}.adjrsquare);
                throw(MException('XYEE:fittingerror','Too few neighbors with high gof to continue fit!'));
            end
            coeffs = coeffs/neighbors;
        end
        opts.StartPoint = coeffs;
        opts.Lower = 0.*coeffs;
        opts.Upper = [10 5e3 5e3 1e4 1e4];
%         opts.Lower = opts.StartPoint - 5*abs(opts.StartPoint);
%         if(opts.Lower(1)<0); opts.Lower(1) = 0; end;
%         if(opts.Lower(3)<0); opts.Lower(3) = 0; end;
%         if(opts.Lower(4)<0); opts.Lower(4) = 0; end;
%         if(opts.Lower(5)<1); opts.Lower(5) = 1; end;
%         if(opts.Lower(6)<0); opts.Lower(6) = 0; end;
%         opts.Upper = opts.StartPoint + 5*abs(opts.StartPoint);
%         opts.Upper(opts.Upper<(opts.Lower+1)) = ...
%             opts.Lower(opts.Upper<(opts.Lower+1)) + 100;
%         opts.Upper(opts.Upper<1) = 100;
        % cn > min(wl), since the Sellmeier equation should remain real
%         if(opts.Upper(3)>140); opts.Upper(3) = 140; end;
        try
            [fitresult, gof] = fit( xData, yData, T_fit, opts );
        catch e
            disp(e.message)
            a.sse = Inf;
            a.rsquare = -Inf;
            a.dfe = Inf;
            a.adjrsquare = -Inf;
            a.rmse = Inf;
            gof = a;
            fitresult = cfit(fittype(T_fit), ...
                opts.StartPoint(:));
        end
%         fitresults{x, y} = fitresult;
%         gofs{x, y} = gof;
    end
end