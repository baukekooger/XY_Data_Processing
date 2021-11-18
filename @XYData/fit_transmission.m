function XYEEobj = fit_transmission(XYEEobj, varargin)
%FIT_TRANSMISSION fits XY transmission spectra to a predefined seed-transmission at x0,y0

%% Setup varargin
varargin = cellflat(varargin);
Data = varargin{1};
x0 = varargin{2};
y0 = varargin{3};
nsub = varargin{4};
d0 = varargin{5};
passes = varargin{6};

%% General functions
    alph    = @(k, wl)(4 * pi * k ./ wl);
    x       = @(k, wl, d)( exp(- alph(k, wl) .* d));
    phi     = @(n, d, wl)( 4 * pi .*n .* d ./ wl);

    A       = @(ns, n, k)(16 * ns * (n.^2 + k.^2));
    B       = @(ns, n, k)( ( (n+1).^2 + k.^2) .* (n+1).*(n+ns.^2) + k.^2);
    C       = @(ns, n, k, d, wl)( ( (n.^2 - 1 + k.^2) .* (n.^2 - ns.^2 + k.^2) ...
        - 2 * k.^2 .* (ns.^2 + 1) ) .* 2 .* cos(phi(n, d, wl)) ...
        - k.* ( 2 .* (n.^2 - ns.^2 + k.^2) + (ns.^2 + 1).*(n.^2 - 1 + k.^2)) ...
        .* 2 .* sin(phi(n, d, wl)));
    D       = @(ns, n, k)( ((n-1).^2 + k.^2) .* ( (n-1).*(n-ns.^2) + k.^2) );

    % Sellmeier equation
    n1 = @(a, b, c, x)( sqrt( a + b .* x.^2 ./ (x.^2 - c.^2)) );
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
    
    %% Initialize data storage
    fitresults = cell(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));
    gofs = cell(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));

    %% Apply Envelope method for intial guess of d, n and k
    inclWl = (Data.Wavelengthnm>310) & (Data.Wavelengthnm<850);
    wl = Data.Wavelengthnm(inclWl);
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Lower = [0 0 0];
    opts.Upper = 280 * [1 1 0.5];
    [xData, yData] = prepareCurveData(Data.Wavelengthnm, Data.Refractive_index);
    [fitresult, ~] = fit(xData, yData, n1 , opts);
    guess_n = [fitresult.a fitresult.b fitresult.c];

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

    T_fit = @(an, bn, cn, ak, bk, ck, dk, ek, d, x)T(nsub, an, bn, cn, ak, bk, ck, dk, ek, d, x);
    [fitresult, gof] =  produce_fit( x0, y0, 0, 0, [guess_n, guess_k, d0] );
    fitresults{x0, y0} = fitresult;
    gofs{x0, y0} = gof;
    
    %% First pass, fill using a seedfit    
       
% try
%     load('fitresults.mat');
% catch
    % Fill downwards
    for ii= (y0+1):size(XYEEobj.spectrum,2)
        fprintf('y=%d\n',ii);
        [fitresult, gof] = produce_fit(x0,ii,0,-1);
        fitresults{x0, ii} = fitresult;
        gofs{x0, ii} = gof;
    end    
    % Fill upwards
    for ii= (y0-1):-1:1
        fprintf('y=%d\n',ii);
        [fitresult, gof] = produce_fit(x0,ii,0,1);
        fitresults{x0, ii} = fitresult;
        gofs{x0, ii} = gof;
    end
    
    for ii=1:size(XYEEobj.spectrum,2)
        % Fill to the right
        for jj=(x0+1):size(XYEEobj.spectrum,1)
            fprintf('x,y=%d,%d\n',jj,ii);
            [fitresult, gof] = produce_fit(jj,ii,-1,0);
            fitresults{jj, ii} = fitresult;
            gofs{jj, ii} = gof;
        end
        % Fill to the left
        for jj=x0:-1:1
            fprintf('x,y=%d,%d\n',jj,ii);
            [fitresult, gof] = produce_fit(jj,ii,1,0);
            fitresults{jj, ii} = fitresult;
            gofs{jj, ii} = gof;
        end
    end
% save('fitresults.mat','fitresults');
% end
    
    %% Blur the resultant coefficient matrix, and perform fitting with these 
    %  blurred values as initial parameters
    
%     disp('Blurring the spectrum!');
%     coeffs = cellfun(@coeffvalues, fitresults, 'UniformOutput', false);
%     ncoeffs = numel(coeffs{1,1});
%     coeff_mat = reshape(cell2mat(coeffs), ...
%         [size(coeffs,1) length(coeffs{1,1}) size(coeffs,2)]);
%     coeff_mat = permute(coeff_mat, [1 3 2]);
%     figure;
%     for ii=1:ncoeffs
%         cmat = squeeze(coeff_mat(:,:,ii));
%         subplot(2,ncoeffs,ii);
%         imagesc(cmat);
%         cmat = imgaussfilt(cmat,1);
%         coeff_mat(:,:,ii) = cmat;
%         subplot(2,ncoeffs,ii+ncoeffs);
%         imagesc(cmat);
%     end
%     for ii = 1:size(fitresults,1)
%         for jj = 1:size(fitresults,2)
%             [fitresult, gof] = produce_fit(ii, jj, 0, 0, ...
%                 squeeze(coeff_mat(ii,jj,:)));
%             fitresults{ii, jj} = fitresult;
%             gofs{ii, jj} = gof;
%         end
%         fprintf('%s: Blurring - progress: %.2f %%\n', ...
%             datestr(now),double(ii)*100/size(fitresults,1));
%     end
    
    %% Higher order passes, fit using surrounding data and choosing the best
    if passes>0
        h = figure;
        h2 = figure;
    end
    for ii=1:passes
        fprintf('Pass %d/%d\n',ii,passes);
        rsq = cellfun(@(x)(x.rsquare),gofs);
        
        % Display these fits' R^2
        figure(h);
        subplot(1,passes,ii);
        imagesc(rsq);
        caxis([0.98 1]);
        
        fitindex = double(rsq>0.99);
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
        
        gof_set = cell([1, 5]);
        fit_set = cell([1, 5]);
        total = sum(sum(double(fitindex>1)));
        progress=0;
        for jj=2:max(reshape(fitindex, [1 numel(fitindex)]))
            indices = find(fitindex==jj);
            for inx=reshape(indices, [1 size(indices)])
                [I,J] = ind2sub(size(fitindex), inx);
                gof_set{1} = gofs{I,J};
                fit_set{1} = fitresults{I,J};
                try
                    [fit_set{2}, gof_set{2}] = produce_fit(I,J,-1,0);
                catch
                    gof_set{2}.rsquare = -Inf;
                end
                try
                    [fit_set{3}, gof_set{3}] = produce_fit(I,J,0,-1);
                catch
                    gof_set{3}.rsquare = -Inf;
                end
                try
                    [fit_set{4}, gof_set{4}] = produce_fit(I,J,1,0);
                catch
                    gof_set{4}.rsquare = -Inf;
                end
                try
                    [fit_set{5}, gof_set{5}] = produce_fit(I,J,0,1);
                catch
                    gof_set{5}.rsquare = -Inf;
                end

                rsq = cellfun(@(x)(x.rsquare),gof_set);
                [~, argmax] = max(rsq);
                fitresults{I, J} = fit_set{argmax};
                gofs{I,J} = gof_set{argmax};
                progress = progress+1;
                fprintf('%s: Pass %d, progress: %.2f %%\n',datestr(now),ii,progress*100/total);

            end
        end
    end
    
    %% Return XYEEobj
    XYEEobj.fitdata.fitresult = fitresults;
    XYEEobj.fitdata.gof = gofs;
    
    %% Helper functions   
    function [fitresult, gof] = produce_fit(x,y,dx,dy, coeffs)
        transmission = squeeze(XYEEobj.spectrum(x,y,inclWl));
        [xData, yData] = prepareCurveData( wl, transmission );
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.Robust = 'Bisquare';
        if (nargin<5 || isempty(coeffs))
            opts.StartPoint = coeffvalues(fitresults{x+dx, y+dy});
        else
            opts.StartPoint = coeffs;
        end
        opts.Lower = opts.StartPoint - 5*abs(opts.StartPoint);
        if(opts.Lower(1)<0); opts.Lower(1) = 0; end;
        if(opts.Lower(3)<0); opts.Lower(3) = 0; end;
        if(opts.Lower(4)<0); opts.Lower(4) = 0; end;
        if(opts.Lower(5)<1); opts.Lower(5) = 1; end;
        if(opts.Lower(6)<0); opts.Lower(6) = 0; end;
        opts.Upper = opts.StartPoint + 5*abs(opts.StartPoint);
        opts.Upper(opts.Upper<(opts.Lower+1)) = ...
            opts.Lower(opts.Upper<(opts.Lower+1)) + 100;
        opts.Upper(opts.Upper<1) = 100;
        % cn > min(wl), since the Sellmeier equation should remain real
        if(opts.Upper(3)>140); opts.Upper(3) = 140; end;
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
        fitresults{x, y} = fitresult;
        gofs{x, y} = gof;
    end
end