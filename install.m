% install
%
% Adds the path to these m-files to your Matlab path so that you can use
% them like 'normal' Matlab functions

mfiles_path = fileparts(mfilename('fullpath'));

if isempty(regexp(path, ['(^|\:)' mfiles_path '(:|$)'], 'once'))
    fprintf('Adding %s to your path\n', mfiles_path);
    addpath(mfiles_path);
    savepath;
else
    fprintf('You already appear to have %s in your path.\n', mfiles_path);
end
