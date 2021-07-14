function [ obj ] = rgb_em_process( obj )
    % RGB_EM_PROCESS translates an XYEE spectral dataset to RGB and CIE
    % coordinates
    %
    %   Author:             Evert PJ Merkx
    %   Contact:            e.p.j.merkx@tudelft.nl
    %   Last revision:      February 14th 2018
    %   Original version:   May 19th 2017
    
    wl = obj.XYEEobj.em_wl;
    if min(wl) > 780
        wl = wl - min(wl);
        wl = wl ./ max(wl);
        wl = wl * (780-360) + 360;
    end
    sm = obj.XYEEobj.spectrum;
    sm = shiftdim(sm,ndims(sm)-1); % "wl" x "x" x "y"
    % For r2xyz to work sm has to be sampled in 10 nm intervals
    sm_v = interp1(wl, sm, 360:10:780);
    sm_v = reshape(sm_v, size(sm_v,1), size(sm_v,2)*size(sm_v,3));
    sm_v = sm_v/max(max(sm_v));

    % D65 selected, since this is MATLAB default for CIE values
    cie = r2xyz(abs(sm_v'), 360, 780, 'd65_64');
    % CIE xy data is scaled as x = X/(X+Y+Z), see 
    % S. Westland and C. Ripamonti, 
    % Computational Colour Science Using MATLAB. 2004. (p. 35, eq. 4.9)

    % Reshape xyz back to image form
    cie = reshape(cie/100, size(sm,2), size(sm,3), 3);
    rgb = xyz2rgb(cie, 'ColorSpace', 'adobe-rgb-1998', 'Whitepoint', 'D65');

    % Scale to whitepoint
    % rgb = rgb/fullmax(rgb);
    rgb(rgb>1) = 1;
    rgb(isnan(rgb)) = 0;
    rgb(rgb<0) = 0;
    
    cform = makecform('xyz2xyl');
    cie(isnan(cie)) =  0;
    obj.xyl = applycform(cie, cform);
    obj.rgb = rgb;
end

