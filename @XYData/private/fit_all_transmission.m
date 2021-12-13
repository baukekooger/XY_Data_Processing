function fit_all_transmission(obj)
% Fit all the xy points. This requires fitdata to be present for one
% datapoint. This data is provided if the single point is fitted with an
% optifit table. 

    % initialize progressbar
    progressbar('Total progress')
    current_progress = 0; 

    %% Constructing indexing matrix. 
    x0 = obj.fitdata.optifit_data.xpoint;
    y0 = obj.fitdata.optifit_data.ypoint; 
    xnum = obj.xystage.xnum; 
    ynum = obj.xystage.ynum; 
    [xinx, yinx] = meshgrid(1:xnum, 1:ynum);
    total = double(xnum * ynum);
    fitted = 1;

    % Fill downwards
    for ii = (y0+1):ynum
%         fprintf('y=%d\n',ii);
        active_area = ((xinx == x0) & (yinx == ii-1));
        [fitresult, gof] = ...
            fit_procedure_transmission(obj, ii, x0, active_area);
        obj.fitdata.fitobjects{ii, x0} = fitresult;
        obj.fitdata.goodnesses{ii, x0} = gof;
        fitted = fitted + 1;
        current_progress = current_progress+1; 
        progressbar(fitted/total);
    end    
    % Fill upwards
    for ii= (y0-1):-1:1
%         fprintf('y=%d\n',ii);
        active_area = (xinx == x0) & (yinx == ii+1);
        [fitresult, gof] = ...
            fit_procedure_transmission(obj, ii, x0, active_area);
        obj.fitdata.fitobjects{ii, x0} = fitresult;
        obj.fitdata.goodnesses{ii, x0} = gof;
        fitted = fitted + 1;
        current_progress = current_progress+1;
        progressbar(fitted/total);
    end

    for ii=1:ynum
        % Fill to the right
        for jj=(x0+1):xnum
%             fprintf('x,y=%d,%d\n',jj,ii);
            active_area = (xinx == jj-1) & (yinx == ii);
            [fitresult, gof] = ...
                fit_procedure_transmission(obj, ii, jj, active_area);
            obj.fitdata.fitobjects{ii, jj} = fitresult;
            obj.fitdata.goodnesses{ii, jj} = gof;
            fitted = fitted + 1;
            current_progress = current_progress+1;
            progressbar(fitted/total);
        end
        % Fill to the left
        for jj=(x0-1):-1:1
%             fprintf('x,y=%d,%d\n',jj,ii);
            active_area = (xinx == jj+1) & (yinx == ii);
            [fitresult, gof] = ...
                fit_procedure_transmission(obj, ii, jj, active_area);
            obj.fitdata.fitobjects{ii, jj} = fitresult;
            obj.fitdata.goodnesses{ii, jj} = gof;   
            fitted = fitted + 1;
            current_progress = current_progress+1;
            disp(current_progress)
            progressbar(fitted/total);
        end
    end
end


% % Store intermediate fittings
% TEMP_FILES = cell(length(passes+1),1);
% FITFILENAME = sprintf('%s_TEMP_TFIT_PASS_%03d.mat', datestr(datetime('now'), 'yymmddHHMMSS'), 0);
% TEMP_FILES{1} = FITFILENAME;
% save(FITFILENAME, 'fitresults', 'gofs');
%     
%     %% Higher order passes, fit using surrounding data and choosing the best
%     if passes>0
%         h = figure;
%         h2 = figure;
%     end
%     for ii=1:passes
%         % Final pass has a "True" T. Other passes use a forced "Real"
%         % compontent, as MATLAB terminates a fit when the outcome turns
%         % imaginary.
%         if ii==passes
%             T_fit =  @(an, bn, ak, bk, ck, dk, ek, d, x)T(nsub, ns_wl, ...
%                 an, bn, ak, bk, ck, dk, ek, d, x);
%         end
%         fprintf('Pass %d/%d\n',ii,passes);
%         rsq = cellfun(@(x)(x.adjrsquare),gofs);
%         
%         % Display these fits' R^2
%         figure(h);
%         subplot(1,passes,ii);
%         imagesc(rsq);
%         caxis([0.98 1]);
%         
%         % Use the top 10% to fit the rest
%         rsq_lin = sort(reshape(rsq, [1 numel(rsq)]));
%         fitindex = double(rsq > rsq_lin(round((1 - topval)*numel(rsq))) );
%         if sum(reshape(fitindex, [1 numel(fitindex)])) < 1
%             disp('Too low Q fit for multiple passes to continue!');
%             return
%         end
%         
%         n = 2;
%         while find(fitindex==0,1)
%             selected_rsq = double(fitindex>0);
%             expanded_rsq = conv2(fitindex, [0 1 0; 1 1 1; 0 1 0], 'same');
%             expanded_rsq = (double(expanded_rsq>0) - selected_rsq)*n;
%             fitindex = fitindex + expanded_rsq;
%             n = n+1;
%         end
%         
%         figure(h2);
%         subplot(1,passes,ii);
%         imagesc(fitindex);
%         
%         gof_set = cell([1, 3]);
%         fit_set = cell([1, 3]);
%         total = sum(sum(double(fitindex>1)));
%         progress=0;
%         total_progress = size(XYEEobj.spectrum,1)*size(XYEEobj.spectrum,2)*(passes+1);
%         current_progress = size(XYEEobj.spectrum,1)*size(XYEEobj.spectrum,2)*(ii);
%         for jj=2:max(reshape(fitindex, [1 numel(fitindex)]))
%             indices = find(fitindex==jj);
%             for inx=reshape(indices, [1 size(indices)])
%                 [I,J] = ind2sub(size(fitindex), inx);
%                 gof_set{1} = gofs{I,J};
%                 fit_set{1} = fitresults{I,J};
%                 try
%                     [fit_set{2}, gof_set{2}] = produce_fit(I,J,fitindex<=jj);
%                 catch e
%                     disp(e.message);
%                     fprintf('Error at x=%d, y=%d\n', I, J);
%                     gof_set{2}.adjrsquare = -Inf;
%                 end
%                 try
%                     [fit_set{3}, gof_set{3}] = produce_fit(I,J,fitindex>-1);
%                 catch
%                     gof_set{3}.adjrsquare = -Inf;
%                 end
% 
%                 rsq = cellfun(@(x)(x.adjrsquare),gof_set);
%                 [~, argmax] = max(rsq);
%                 fitresults{I, J} = fit_set{argmax};
%                 gofs{I,J} = gof_set{argmax};
%                 progress = progress+1;
%                 current_progress = current_progress + 1;
%                 progressbar(current_progress/total_progress , 1, progress/total);
%             end
% %             fprintf('%s: Pass %d, progress: %.2f %%\n',datestr(now),ii,progress*100/total);
%         end
%     FITFILENAME = sprintf('%s_TEMP_TFIT_PASS_%03d.mat', ...
%         datestr(datetime('now'), 'yymmddHHMMSS'), ii);
%     TEMP_FILES{ii+1} = FITFILENAME;
%     save(FITFILENAME, 'fitresults', 'gofs');
%     end
%     progressbar(1);
%     
%     %% Return XYEEobj
%     XYEEobj.fitdata.fitresult = fitresults;
%     XYEEobj.fitdata.gof = gofs;
%     
%     % Remove temporary clutter
%     for ii=1:length(TEMP_FILES)
%         delete(TEMP_FILES{ii});
%     end
    


