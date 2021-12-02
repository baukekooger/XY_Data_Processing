function k = extinction_coefficient(XYEEobj, varargin)
% extinction_coefficient yields the extinction coefficients as fitted

k1 = @(a, b, c, d, e, x)( 1240*a .* x  .* (1./x - 1./b).^2 .* heaviside(b-x) ...
        + c + d./x + e./x.^2 );
    
v = cellfun(@(x)(k1(x.ak, x.bk, x.ck, x.dk, x.ek, XYEEobj.em_wl)), ...
    XYEEobj.fitdata.fitresult, 'UniformOutput', false);

k = zeros(size(squeeze(XYEEobj.spectrum)));
for ii=1:size(v,1)
    for jj=1:size(v,2)
        k(ii,jj,:) = v{ii,jj};
    end
end

end