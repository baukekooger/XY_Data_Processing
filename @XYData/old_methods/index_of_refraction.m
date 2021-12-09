function n = index_of_refraction(XYEEobj, varargin)
% extinction_coefficient yields the extinction coefficients as fitted

n1 = @(a, b, x)( sqrt( 1 + a .* x.^2 ./ (x.^2 - b.^2)));
    
v = cellfun(@(x)(n1(x.an, x.bn, XYEEobj.em_wl)), ...
    XYEEobj.fitdata.fitresult, 'UniformOutput', false);

n = zeros(size(squeeze(XYEEobj.spectrum)));
for ii=1:size(v,1)
    for jj=1:size(v,2)
        n(ii,jj,:) = v{ii,jj};
    end
end

end