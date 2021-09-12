function Menu(varargin)
%varargin = {'hot dog', 1, 2, 3};
str = varargin{1};
switch lower(str) %make it case insensitive. all lower cases
    case 'hot dog'
        disp('Delicious hot dogs!')
    case 'burger'
        disp('Mouth-watering burgers!')
end