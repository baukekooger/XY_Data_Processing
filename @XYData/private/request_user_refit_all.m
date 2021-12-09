function passed = request_user_refit_all
% Make a messagebox notifying the user there is already fitted data for
% each point, and that continuing means this data will be overwritten. 

    fig = uifigure;
    msg = ['Fitdata already present for each point in film. Refitting ' ...
        'means old fitting data will be overwritten. Please select ' ...
        'how to continue'];
    title = 'Fitdata already present';
    selection = uiconfirm(fig, msg, title, ...
       'Options',{'Continue and fit', ... 
       'Continue without fitting'});
    switch selection
        case 'Continue without fitting'
            close(fig)
            clear('fig')
            passed = false; 
            return
        case 'Continue and fit'
            close(fig)
            clear('fig') 
            passed = true;
            return
    end
end