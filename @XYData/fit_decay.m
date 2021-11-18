function XYEEobj = fit_decay(XYEEobj, varargin)
% FIT_DECAY fits a triple exponential to the input XYEEObject
% Outputs:
% P (struct)
% |- gof: x by y Cell containing the goodness of fit
% |- fit:
%

varargin = cellflat(varargin);
exclStart = varargin{1};

%% Turn off specific warnings
warning('off', 'curvefit:prepareFittingData:sizeMismatch');

%% Prepare fitobject
xy = XYEEobj.spectrum;
t = XYEEobj.time;

sz = size(XYEEobj.spectrum);
P.gof = cell(sz(1:end-1));
P.fit = cell(sz(1:end-1));

% World's ugliest nested for-loop...
progress = 0;
for xi = 1:sz(1)
    for yi = 1:sz(2)
        for exii = 1:sz(3)
            for emii = 1:sz(4)
                try
%                     % Check Signal/Noise. Should have 8x more signal than
%                     % noise
%                     spectrum = squeeze(xy(xi,yi,exii,emii,:));
%                     spectrum(spectrum<0) = 0;
%                     sn = sum(spectrum(spectrum<1))./sqrt(sum(spectrum(spectrum<1)));
%                     if sn<8
%                         error('Too low S/N ratio!');
%                     end
                    % Fit!
                    [P.fit{xi, yi, exii, emii}, P.gof{xi, yi, exii, emii}] = ...
                        lindecayfit(t, squeeze(xy(xi, yi, exii, emii, :)));
                catch e
                    fprintf('Not able to fit (%d,%d,%d,%d)\n', ...
                        xi, yi, exii, emii);
                    disp(e.message);
                    a.sse = Inf;
                    a.rsquare = 0;
                    a.dfe = Inf;
                    a.adjrsquare = 0;
                    a.rmse = Inf;
                    P.gof{xi, yi, exii, emii} = a;
                    P.fit{xi, yi, exii, emii} = cfit(fittype(...
                        'a * b * c * d * e * f * x'), 0, 0, 0, 0, 0, 0);
                end
                progress = progress + 1;
            end
            fprintf('Progress: %.2f %%\n', progress / prod(sz(1:end-1)) *100);
        end
    end
end

%% Turn on specific warnings
warning('on', 'curvefit:prepareFittingData:sizeMismatch');

%% Return the XYEEobj
XYEEobj.fitdata = P;

function [fitresult, gof] = lindecayfit(x, y)
    ly = real(log(y*1e5));
    [xData, yData] = prepareCurveData( x, ly );

    noise = max(yData(xData<-10))*0.75;
%     exclStart = exclStart;
    exclEnd = max(xData);
    [fres, rmse, adjrsq] = fitMe(xData, yData, exclStart, exclEnd, noise);

    [~, argmax] = max(adjrsq);
    optimalFit_e1 = fres{argmax};
        
    exclStart = exclStart - exclStart/30*argmax;
    substr = (optimalFit_e1.p1 * xData + optimalFit_e1.p2);
    yData = yData - substr;

    exclEnd = xData(find(yData(xData>0)<0, 1)+find(xData==0));
    if exclEnd<=exclStart
        exclStart = exclEnd-1;
    end
    [fres, rmse, adjrsq] = fitMe(xData, yData, exclStart, exclEnd, 0);

    [~, argmax] = max(adjrsq);
    optimalFit_e2 = fres{argmax};
    substr = (optimalFit_e2.p1 * xData + optimalFit_e2.p2);
    yData = yData - substr;

    exclEnd = xData(find(yData(xData>0)<0,1)+find(xData==0));

    [fres, rmse, adjrsq] = fitMe(xData, yData, 10, exclEnd, 0);

    [~, argmax] = max(adjrsq);
    optimalFit_e3 = fres{argmax};

    %% Fit to retrieve intensities (course fitting)
    [xData, yData] = prepareCurveData( x, y );

    % Set up fittype and options.
    ft = fittype( 'a*exp(x*b) + c*exp(x*d) + e*exp(x*f)', 'independent', 'x', 'dependent', 'y' );
    excludedPoints = (xData < 10);
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 optimalFit_e1.p1 0 optimalFit_e2.p1 0 optimalFit_e3.p1];
    opts.MaxFunEvals = 6000;
    opts.MaxIter = 4000;
    opts.Robust = 'Bisquare';
    opts.StartPoint = [0.1 optimalFit_e1.p1 0.1 optimalFit_e2.p1 0.1 optimalFit_e3.p1];
    opts.Upper = [Inf optimalFit_e1.p1 Inf optimalFit_e2.p1 Inf optimalFit_e3.p1];
    opts.Exclude = excludedPoints;

    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );

    %% Full free fitting
    [xData, yData] = prepareCurveData( x, y );

    % Set up fittype and options.
    ft = fittype( 'a*exp(x*b) + c*exp(x*d) + e*exp(x*f)', 'independent', 'x', 'dependent', 'y' );
    % Define noise as 75% of the maximal yData, 5 ns before the trigger
    noise = max(yData(xData<-10))*0.75;
    excludedPoints = (xData < 10) | (yData < noise);
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 -1 0 -1 0 -1];
    opts.MaxFunEvals = 6000;
    opts.MaxIter = 4000;
    opts.Robust = 'Bisquare';
    opts.StartPoint = [fitresult.a fitresult.b fitresult.c fitresult.d fitresult.e fitresult.f];
    opts.Upper = [Inf 0 Inf 0 Inf 0];
    opts.Exclude = excludedPoints;

    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    
%     % Create a figure for the plots.
%     figure( 'Name', 'untitled fit 1' );
% 
%     % Plot fit with data.
%     h = plot( fitresult, xData, yData );
%     legend( h, 'ly vs. x', 'Excluded ly vs. x', 'untitled fit 1', 'Location', 'NorthEast' );
%     % Label axes
%     xlabel x
%     ylabel ly
%     grid on
end

function [fres, rmse, adjrsq] = fitMe(xData, yData, exclStart, exclEnd, noise)
    % Set up fittype and options.
    ft = fittype( 'poly1' );
    opts = fitoptions( 'Method', 'LinearLeastSquares' );
    opts.Lower = [-1 0];
    opts.Upper = [0 Inf];

    n = 30;
    fres = cell(n,1);
    rmse = zeros(n,1);
    adjrsq = zeros(n,1);

    for ii=1:n
        % Fit model to data.
        excludedPoints = (xData < exclStart - exclStart/n*ii) | (yData < noise);
        excludedPoints = excludedPoints | (xData > exclEnd);
        opts.Exclude = excludedPoints;
        [fitresult, gof] = fit( xData, yData, ft, opts );
        fres{ii} = fitresult;
        rmse(ii) = gof.rmse;
        adjrsq(ii) = gof.adjrsquare;
    end
end
end