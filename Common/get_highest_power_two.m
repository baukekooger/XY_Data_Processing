function highest_power = get_highest_power_two(input)
% get the highset power of two the input can be divided by without a
% remainder
    arguments
        input (1,1) int32 {mustBePositive} 
    end
    
    power = 0; 
    while mod(input, 2^power) == 0
        power = power + 1;
    end
    highest_power = power -1; 

end





