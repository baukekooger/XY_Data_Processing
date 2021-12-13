function passed = request_user_optifit_data(obj)
% Make a messagebox notifying the user there is no optifit data and
% the fitting cannot continue. Ask if they want to select a file or
% continue
    fig = uifigure;
    msg = ['No optifit fitting data found. Please select an optifit ' ...
        'output (..Data.dat) file if fitting is desired.'];
    title = 'No optifit data';
    selection = uiconfirm(fig, msg, title, ...
       'Options',{'Select file', ... 
       'Continue without fitting'});
    switch selection
        case 'Select file'
            close(fig)
            clear('fig')
            passed = read_optifit_data(obj); 
            return
        case 'Continue without fitting'
            close(fig)
            clear('fig') 
            passed = false;
            return
    end
end

