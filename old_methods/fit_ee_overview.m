function fit_ee_overview( obj )
%FIT_EE_OVERVIEW plots on overview of the fitted XYEE emission scan data

peakEmFull = cellfun(@(x)(1240 ./ x.Center(1,:)), ...
    obj.fitdata, 'UniformOutput', false);
peakWidthFull = cellfun(@(x)(x.Width(1,:)), ...
    obj.fitdata, 'UniformOutput', false);
peakHeightFull = cellfun(@(x)(x.Height(1,:)), ...
    obj.fitdata, 'UniformOutput', false);
peakAreaFull = cellfun(@(x)(x.Area(1,:)./sum(x.Area(1,:))), ...
    obj.fitdata, 'UniformOutput', false);
gofs = cellfun(@(x)(x.AdjCoeffDeterm), obj.fitdata, 'UniformOutput', false);
nanmat = double(cell2mat(gofs)>0.95);
nanmat(nanmat<1) = nan;
nanmat = permute(nanmat, [2 1]);

lt = length(peakEmFull{1,1});
for ii=1:lt
    if ~mod(ii-1,4)
        f = figure;
    end
    Cx = cell2mat(cellfun(@(x)(x(ii)), peakEmFull, 'UniformOutput', false));
    Cx = permute(Cx, [2 1]);
    Wx = cell2mat(cellfun(@(x)(x(ii)), peakWidthFull, 'UniformOutput', false));
    Wx = permute(Wx, [2 1]);
    Ax = cell2mat(cellfun(@(x)(x(ii)), peakAreaFull, 'UniformOutput', false));
    Ax = permute(Ax, [2 1]);
    Hx = cell2mat(cellfun(@(x)(x(ii)), peakHeightFull, 'UniformOutput', false));
    Hx = permute(Hx, [2 1]);
    
    figure(f);
    ax = subplot(4, 4, 1 + 4 * mod(ii-1,4));
    him = imagesc(Cx.*nanmat);
    hold all;
    [C, h] = contour(1240./Cx.*nanmat, 'color','k');
    clabel(C, h, 'FontSize', 10);
    set(him,'alphadata',~isnan(nanmat));
    colormap(ax, 'jet')
    caxis([300 900]);
    ax.XTick = [];
    ax.YTick = [];
    if ~mod(ii-1,4)
        title('Center (eV)');
    end
    ax = subplot(4, 4, 2 + 4 * mod(ii-1,4));
    him = imagesc(Ax.*nanmat);
    hold all;
    [C, h] = contour(Ax.*nanmat, 'color','k');
    clabel(C, h, 'FontSize', 10);
    set(him,'alphadata',~isnan(nanmat));
    caxis([0 1]);
    ax.XTick = [];
    ax.YTick = [];
    if ~mod(ii-1,4)
        title('Area (%)');
    end
    ax = subplot(4, 4, 3 + 4 * mod(ii-1,4));
    him = imagesc(Wx.*nanmat);
    hold all;
    [C, h] = contour(Wx.*nanmat, 'color','k');
    clabel(C, h, 'FontSize', 10);
    set(him,'alphadata',~isnan(nanmat));
    ax.XTick = [];
    ax.YTick = [];
    if ~mod(ii-1,4)
        title('Width (eV)');
    end
    ax = subplot(4, 4, 4 + 4 * mod(ii-1,4));
    him = imagesc(Hx.*nanmat);
    hold all;
    [C, h] = contour(Hx.*nanmat, 'color','k');
    clabel(C, h, 'FontSize', 10);
    set(him,'alphadata',~isnan(nanmat));
    ax.XTick = [];
    ax.YTick = [];
    if ~mod(ii-1,4)
        title('Height (a.u.)');
    end
end

end
