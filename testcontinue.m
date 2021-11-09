

for ii = 1:10
    for jj = 1:10 
        if mod(jj+ii, 6)
            continue
        end
        disp(['Divisible by 3:' num2str(ii+jj) ' ii = ' num2str(ii) ' jj = ' num2str(jj)])
    end
end

        
            