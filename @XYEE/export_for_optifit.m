function XYEEobj = export_for_optifit(XYEEobj, x, y, varargin)
% EXPORT_FOR_OPTIFIT exports the desired location to an OPTIFIT compatible
% file

filename = XYEEobj.fname(1:end-5);
for ii=1:2:length(varargin)
    switch varargin{ii}
        case {'filename', 'f'}
            filename = varargin{ii+1};
    end
end

spectrum = squeeze(XYEEobj.spectrum(x,y,:,1,:));
filename = sprintf('%s_x%.2d_y%.2d.csv',filename,x,y);
csvwrite(filename, ...
    [flatmat(XYEEobj.em_wl), flatmat(spectrum)*100]);
end