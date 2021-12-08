function passed = request_user_refit_singlefit
% Make a messagebox notifying the user there is already a seed fit present
% and ask if they want to continue with the current fit, or proceed with
% refitting the seedfit with selected optifit data. 

    fig = uifigure;
    msg = ['Fitdata already present. Do you still want to refit ' ...
        'this point with optifit fitdata?'];
    title = 'Fitdata present';
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