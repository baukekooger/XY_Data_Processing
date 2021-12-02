function XYEEobj = fit_transmission2(XYEEobj, varargin)
%FIT_TRANSMISSION fits XY transmission spectra to a predefined seed-transmission at x0,y0

%% Setup varargin
varargin = cellflat(varargin);
Data = varargin{1};
x0 = varargin{2};
y0 = varargin{3};
nsub = varargin{4};
d0 = varargin{5};
passes = varargin{6};
vararginstart = 7;
try
    wlmin = varargin{7};
    wlmax = varargin{8};
    vararginstart = 9;
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
n1 = @(a, b, x)( sqrt( 1 + b .* x.^2 ./ (x.^2 - c.^2)) );
% Band gap-included Taylor expansion dispersion relation
% All factors of the BG-term have a lower limit of 0
% Others are free
k1 = @(a, b, c, d, e, x)( 1240*a .* x  .* (1./x - 1./b).^2 .* heaviside(b-x) ...
        + c + d./x + e./x.^2 );

T = @(ns, an, bn, cn, ak, bk, ck, dk, ek, d, wl)( A(ns, n1(an, bn, cn, wl),...
    k1(ak, bk, ck, dk, ek, wl)) .* x(k1(ak, bk, ck, dk, ek, wl), wl, d) ./ ...
    ( B(ns, n1(an, bn, cn, wl), k1(ak, bk, ck, dk, ek, wl)) - ...
    C(ns, n1(an, bn, cn, wl), k1(ak, bk, ck, dk, ek, wl), d, wl) .* ...
    x(k1(ak, bk, ck, dk, ek, wl), wl, d) + ...
    D(ns, n1(an, bn, cn, wl), k1(ak, bk, ck, dk, ek, wl)) .* ...
    (x(k1(ak, bk, ck, dk, ek, wl), wl, d)).^2) );

% Force "Real" on Transmission
inclWl  = (XYEEobj.em_wl>wlmin) & (XYEEobj.em_wl<wlmax);
wl      = XYEEobj.em_wl(inclWl);
[~, nsub] = prepareCurveData(wl, nsub);
T_fit = @(an, bn, cn, ak, bk, ck, dk, ek, d, x)real(T(nsub, an, bn, cn, ak, bk, ck, dk, ek, d, x));

%% Initialize data storage
fitresults = cell(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));
gofs = cell(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));

if skip_first
    fitresults = XYEEobj.fitdata.fitresult;
    gofs = XYEEobj.fitdata.gof;
else
    %% Apply Envelope method for intial guess of d, n and k
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Lower = [0 0 0];
    opts.Upper = 280 * [1 1 0.5];
    [xData, yData] = prepareCurveData(Data.Wavelengthnm, Data.Refractive_index);
    [fitresult, ~] = fit(xData, yData, n1 , opts);
    guess_n = [fitresult.a fitresult.b fitresult.c]

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
    guess_k = [fitresult.a fitresult.b fitresult.c fitresult.d fitresult.e]
    transmission = squeeze(XYEEobj.spectrum(x0,y0,inclWl));

    subplot(2,1,2); 
    plot(Data.Wavelengthnm, Data.Extintion_coefficient, 'b-');
    hold all;
    plot(Data.Wavelengthnm, fitresult(Data.Wavelengthnm), ...
        'k--', xData, yData, '.');
    title('k');
    
    [fitresult, gof] =  produce_fit( x0, y0, 0, [guess_n, guess_k, d0] );
    fitresults{x0, y0} = fitresult;
    gofs{x0, y0} = gof;
    
    [yinx, xinx] = meshgrid(1:size(XYEEobj.spectrum,1), 1:size(XYEEobj.spectrum,2));
    % Fill downwards
    for ii= (y0+1):size(XYEEobj.spectrum,2)
        fprintf('y=%d\n',ii);
        active_area = ((xinx == x0) & (yinx == ii-1));
        [fitresult, gof] = produce_fit(x0,ii,active_area);
        fitresults{x0, ii} = fitresult;
        gofs{x0, ii} = gof;
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
end
    
    %% Higher order passes, fit using surrounding data and choosing the best
    if passes>0
        h = figure;
        h2 = figure;
    end
    for ii=1:passes
        % Final pass has a "True" T
        if ii==passes
            T_fit = @(an, bn, cn, ak, bk, ck, dk, ek, d, x)T(nsub, an, bn, cn, ak, bk, ck, dk, ek, d, x);
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
        opts.Display = 'Off';
        opts.Robust = 'Bisquare';
        try
            fields = fieldnames(custom_fitoptions);
        catch
            fields = [];
        end
        for fii=1:length(fields)
            f = fields{ii};
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
                throw(MException('XYEE:fittingerror',...
                    sprintf('Too few neighbors at (x,y)=(%d, %d) with high gof to continue fit!', ...
                    x, y)));
            end
            coeffs = coeffs/neighbors;x
        end
        opts.StartPoint = coeffs;
        opts.Lower = opts.StartPoint - 5*abs(opts.StartPoint) - 10;
        if(opts.Lower(1)<0); opts.Lower(1) = 0; end;
        if(opts.Lower(2)<0); opts.Lower(2) = 0; end;
        if(opts.Lower(3)<0); opts.Lower(3) = 0; end;
        if(opts.Lower(4)<0); opts.Lower(4) = 0; end;
        if(opts.Lower(5)<1); opts.Lower(5) = 1; end;
%         if(opts.Lower(6)<0); opts.Lower(6) = 0; end;
        opts.Upper = opts.StartPoint + 5*abs(opts.StartPoint) + 10;
        opts.Upper(opts.Upper<(opts.Lower+1)) = ...
            opts.Lower(opts.Upper<(opts.Lower+1)) + 100;
        opts.Upper(opts.Upper<1) = 100;
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
                opts.StartPoint(1),...
                opts.StartPoint(2),...
                opts.StartPoint(3),...
                opts.StartPoint(4),...
                opts.StartPoint(5),...
                opts.StartPoint(6),...
                opts.StartPoint(7),...
                opts.StartPoint(8),...
                opts.StartPoint(9));
        end
%         fitresults{x, y} = fitresult;
%         gofs{x, y} = gof;
    end
end