function XYEEobj = fit_ee(XYEEobj, varargin)
% FIT_EE fits a number of gaussians specified by an initial guess
% to an XYEE measurement.
% Outputs:
% P:

% Flatten varargin
varargin = cellflat(varargin);
guess = varargin{1};
x0 = varargin{2};
y0 = varargin{3};
passes = varargin{4};

%% Initialize data storage
fitresults = cell(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));
gofs = cell(size(XYEEobj.spectrum,1), size(XYEEobj.spectrum,2));

%% Prepare fitobject
xy = squeeze(XYEEobj.spectrum);
xy(xy<0) = 0;
wl = XYEEobj.em_wl;
obj = PeakFit();
obj.CenterStart = guess(1:2:end);
obj.WidthStart = guess(2:2:end);
obj.PeakShape = 'G';
obj.BaselinePolyOrder = -1; % No baseline required

mp = 0;
for ii=5:2:length(varargin)
    switch varargin{ii}
        case 'emission'
            %Convert xy data to energy scale
            if varargin{ii+1}
                xy = xy .* permute(repmat(wl.^2,[1 size(xy,1) size(xy,2)]), ...
                    [2 3 1]);
            end
        case 'emission_norm'
            %Convert xy data to energy scale
            if varargin{ii+1}
                xy = xy .* permute(repmat(wl.^2,[1 size(xy,1) size(xy,2)]), ...
                    [2 3 1]);
                xy = xy./repmat(max(xy(:,:,find(XYEEobj.em_wl>300,1):end),[],3),[1 1 size(xy,3)]);
            end
    end
end

%% First pass, fill using a seedfit
prepare_fitObj(x0,y0);
obj = apply_options(obj);
fitresults{x0,y0} = PeakFit(obj);
figure; plot(fitresults{x0,y0}.XData, fitresults{x0,y0}.YData, ...
    fitresults{x0,y0}.XData, fitresults{x0,y0}.model);
hold all;
ls = size(fitresults{x0,y0}.Area, 2);
for ii=1:ls
    center = fitresults{x0,y0}.Center(1, ii);
    height = fitresults{x0,y0}.Height(1, ii);
    width = fitresults{x0,y0}.Width(1, ii);
    g = PeakFit.fngaussian(fitresults{x0,y0}.XData, center, height, width);
    plot(fitresults{x0,y0}.XData, g, 'k-');
end
% try
%     load('frs.mat');
%     fresloaded = 1;
% catch
%     fresloaded = 0;
% end
% if ~fresloaded
% Fill downwards
for ii= (y0+1):size(XYEEobj.spectrum,2)
    fprintf('y=%d\n',ii);
    [fitresult, gof] = fit_using_previous(x0,ii,0,-1);
    fitresults{x0, ii} = fitresult;
    gofs{x0, ii} = gof;
end    
% Fill upwards
for ii= (y0-1):-1:1
    fprintf('y=%d\n',ii);
    [fitresult, gof] = fit_using_previous(x0,ii,0,1);
    fitresults{x0, ii} = fitresult;
    gofs{x0, ii} = gof;
end

for ii=1:size(XYEEobj.spectrum,2)
    % Fill to the right
    for jj=(x0+1):size(XYEEobj.spectrum,1)
        fprintf('x,y=%d,%d\n',jj,ii);
        [fitresult, gof] = fit_using_previous(jj,ii,-1,0);
        fitresults{jj, ii} = fitresult;
        gofs{jj, ii} = gof;
    end
    % Fill to the left
    for jj=x0:-1:1
        fprintf('x,y=%d,%d\n',jj,ii);
        [fitresult, gof] = fit_using_previous(jj,ii,1,0);
        fitresults{jj, ii} = fitresult;
        gofs{jj, ii} = gof;
    end
end
% end
% save('frs.mat','fitresults','gofs');

%% Display results for primary fitting
% 
% fitoverview = XYEEobj;
% fitoverview.fitdata = fitresults;
% fitoverview.fit_ee_overview();
% 
% clear fitoverview;

%% Higher order passes, fit using surrounding data and choosing the best
if passes>0
    h = figure;
    h2 = figure;
end
for ii=1:passes
    fprintf('Pass %d/%d\n',ii,passes);
    rsq = cell2mat(gofs);

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
                [fit_set{2}, gof_set{2}] = fit_using_surroundings(I,J, fitindex<=jj);
            catch
                fprintf('Error at x=%d, y=%d\n', I, J);
                gof_set{2} = -Inf;
                disp(cell2mat(gof_set));
            end
            try
                [fit_set{3}, gof_set{3}] = fit_using_surroundings(I,J, ...
                    fitindex>-1);
            catch
                fprintf('Error at x=%d, y=%d\n', I, J);
                gof_set{3} = -Inf;
                disp(cell2mat(gof_set));
            end

            rsq = cell2mat(gof_set);
            [~, argmax] = max(rsq);
            fitresults{I, J} = fit_set{argmax};
            gofs{I,J} = gof_set{argmax};
            progress = progress+1;

        end
		fprintf('%s: Pass %d, progress: %.2f %%\n',datestr(now),ii,progress*100/total);
    end
end

%% Return the XYEEObj
XYEEobj.fitdata = fitresults;
        
%% Local functions
    function prepare_fitObj(x,y)
        X = 1240./wl;
        Y = squeeze(xy(x,y,:));
        [X,Y] = prepareCurveData(X,Y);
        [X, ix] = sort(X);
        Y = Y(ix);
        X(isnan(Y) | isinf(Y)) = [];
        Y(isnan(Y) | isinf(Y)) = [];
        obj.XData = X; 
        try
            obj.YData = Y;
        catch
            disp(Y);
        end
    end
    
    function [fitresult, gof] = fit_using_previous(x,y,dx,dy)
        prepare_fitObj(x,y);
        if gofs{x+dx, y+dy} > 0.96
            obj.CenterStart = fitresults{x+dx, y+dy}.Center(1,:);
            obj.WidthStart = fitresults{x+dx, y+dy}.Width(1,:);
            obj.HeightStart = fitresults{x+dx, y+dy}.Height(1,:);
        else
            obj.CenterStart = fitresults{x+dx, y+dy}.CenterStart;
            obj.WidthStart = fitresults{x+dx, y+dy}.WidthStart;
            obj.HeightStart = fitresults{x+dx, y+dy}.HeightStart;
        end
        obj = apply_options(obj);
        try
            fitresult = PeakFit(obj);
        catch e
            fprintf('Error at x=%d, y=%d\n', x, y);
            disp(e.message);
            fitresult = fitresults{x+dx, y+dy};
        end
        gof = fitresult.AdjCoeffDeterm;
    end

    function [fitresult, gof] = fit_using_surroundings(x,y,active_area)
        prepare_fitObj(x,y);
        neighbors = 0;
        obj.CenterStart = 0;
        obj.WidthStart = 0;
        obj.HeightStart = 0;
        for dx=-1:1
            for dy=-1:1
                if abs(dx)==abs(dy)
                    continue;
                end
                try
                    if active_area(x+dx, y+dy)==0
                        continue;
                    end
                catch
                    continue;
                end
                try
                    if gofs{x+dx, y+dy} > 0.96
                        obj.CenterStart = obj.CenterStart + ...
                            fitresults{x+dx, y+dy}.Center(1,:);
                        obj.WidthStart = obj.WidthStart + ...
                            fitresults{x+dx, y+dy}.Width(1,:);
                        obj.HeightStart = obj.HeightStart + ...
                            fitresults{x+dx, y+dy}.Height(1,:);
                    else
                        obj.CenterStart = obj.CenterStart + ...
                            fitresults{x+dx, y+dy}.CenterStart;
                        obj.WidthStart = obj.WidthStart + ...
                            fitresults{x+dx, y+dy}.WidthStart;
                        obj.HeightStart = obj.HeightStart + ...
                            fitresults{x+dx, y+dy}.HeightStart;
                    end
                    neighbors = neighbors+1;
                catch
                    continue;
                end
            end
        end
        obj.CenterStart = obj.CenterStart/neighbors;
        obj.WidthStart = obj.WidthStart/neighbors;
        obj.HeightStart = obj.HeightStart/neighbors;
        obj = apply_options(obj);

        fitresult = PeakFit(obj);

        gof = fitresult.AdjCoeffDeterm;
    end

    function [fitresult, gof] = blur_fit(x,y,C,W,H)
        prepare_fitObj(x,y);
        obj.CenterStart = C;
        obj.WidthStart = W;
        obj.HeightStart = H;
        obj = apply_options(obj);
        try
            fitresult = PeakFit(obj);
        catch e
            fprintf('Error at x=%d, y=%d\n', x, y);
            disp(e);
            fitresult = PeakFit();
        end
        gof = fitresult.AdjCoeffDeterm;
    end

    function obj = apply_options(obj)
        % Apply the options mentioned in varargin to the fitobject
        for ii_opt=5:2:length(varargin)
            switch varargin{ii_opt}
                case {'position_bounds', 'positionbounds', 'pb'}
                    % All peaks should be held to these bounds (in nm)
                    xpct = varargin{ii_opt+1};
                    obj.CenterLow = 1240./(1240./obj.CenterStart - xpct);
                    obj.CenterUp = 1240./(1240./obj.CenterStart + xpct);
                case {'position_bounds_eV', 'positionboundsev', 'pbev'}
                    % All peaks should be held to these bounds (in eV)
                    xpct = varargin{ii_opt+1};
                    obj.CenterLow   = max(0, obj.CenterStart - xpct);
                    obj.CenterUp    = obj.CenterStart + xpct;
                case {'x_percent_center_bounds', 'xpercentcenterbounds', 'xpcb'}
                    xpct = varargin{ii_opt+1};
                    obj.CenterLow = (1-xpct).*obj.CenterStart;
                    obj.CenterUp = (1+xpct).*obj.CenterStart;
                case {'width_bounds', 'widthbounds', 'wb'}
                    % All peaks should be held to these widths (in nm)
                    xpct = varargin{ii_opt+1};
                    obj.WidthLow = 1240./(1240./obj.WidthStart - xpct);
                    obj.WidthUp = 1240./(1240./obj.WidthStart + xpct);
                case {'width_bounds_eV', 'widthboundsev', 'wbev'}
                    % All peaks should be held to these widths (in eV)
                    xpct = varargin{ii_opt+1};
                    obj.WidthLow = max(0, obj.WidthStart - xpct);
                    obj.WidthUp = obj.WidthStart + xpct;
                case {'x_percent_width_bounds', 'xpercentwidthbounds', 'xpwb'}
                    xpct = varargin{ii_opt+1};
                    obj.WidthLow = (1-xpct).*obj.WidthStart;
                    obj.WidthUp = (1+xpct).*obj.WidthStart;
                case {'height_bounds', 'heightbounds', 'hb'}
                    xpct = varargin{ii_opt+1};
                    obj.HeightLow = bsxfun(@max, obj.HeightStart - xpct, 0);
                    obj.HeightUp = obj.HeightStart + xpct;
                case {'height_bounds_with_max_height', 'heightboundsmaxheight', 'hbmh'}
                    xpct1 = varargin{ii_opt+1}(1,:);
                    xpct2 = varargin{ii_opt+1}(2,:);
                    try
                        obj.HeightLow = bsxfun(@max, 0, obj.HeightStart - xpct1);
                        obj.HeightUp = bsxfun(@min, xpct2, obj.HeightStart + xpct1);
                    catch e
                        switch e.identifier
                            case 'MATLAB:dimagree'
                                continue;
                            otherwise
                                rethrow(e)
                        end
                    end
                case {'x_percent_height_bounds', 'xpercentheightbounds', 'xphb'}
                    xpct = varargin{ii_opt+1};
                    obj.HeightLow = (1-xpct).*obj.HeightStart;
                    obj.HeightUp = (1+xpct).*obj.HeightStart;
                case {'maximal_area', 'maximalarea', 'maxA'}
                    xpct = varargin{ii_opt+1};
                    obj.AreaUp = xpct;
                    obj.AreaLow = 0;
                case {'window', 'w'}
                    obj.Window = varargin{ii_opt+1};
                case {'weight', 'wt'}
                    wt = flipud(varargin{ii_opt+1});
                    obj.Weights = wt;
                case {'robust', 'r'}
                    obj.Robust = varargin{ii_opt+1};
            end
        end
    end
end