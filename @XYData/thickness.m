function d = thickness(XYEEobj, varargin)
%THICKNESS returns the thickness of a fitted XY transmission spectrum
%
% AUTHOR
% Evert Merkx
% E-MAIL
% e.p.j.merkx at tudelft.nl
% LAST REVISION
% 25-02-2019
%
%
d = cellfun(@(x)(x.d),XYEEobj.fitdata.fitresult);    

end