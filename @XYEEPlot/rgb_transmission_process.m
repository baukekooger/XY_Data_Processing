function [ obj ] = rgb_transmission_process( obj )
    % RGB_EM_PROCESS translates an XYEE spectral dataset to RGB and CIE
    % coordinates
    %
    %   Author:             Evert PJ Merkx
    %   Contact:            e.p.j.merkx@tudelft.nl
    %   Last revision:      October 10th 2017
    %   Original version:   May 19th 2017
    
%     rgb = rand([size(obj.XYEEobj.spectrum,1) size(obj.XYEEobj.spectrum,2)]);
    sp = shiftdim(obj.XYEEobj.spectrum, 2);
    em_wl = obj.XYEEobj.em_wl;
    inx = ( (em_wl>500) & (em_wl<600) );
    rgb = squeeze(trapz(obj.XYEEobj.em_wl(inx), sp(inx,:,:)));
%     rgb = squeeze(obj.XYEEobj.spectrum(:,:,find(em_wl>=350,1)));
%     rgb = permute(rgb, [2 1]);
    obj.rgb = rgb;
end

