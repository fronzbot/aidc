% Kevin Fronczak
% aidc
% aidc.m
% 2013.07.25

function [fit] = aidc(options)
% ie. fit = aidc({'Algorithm', 'PSO', 'Print', true, 'Plot', false})

% OPTIONS
% mode = 'DCM' or 'CCM'
% L, R, C, Vo, Vs, Fs = any numerical value
% Algorithm = 'GA' or 'PSO'
% PSOType = 'Constrict' or 'Weight'
% Iter, Size = any integer > 0
% Print = true/false.  Set to true to print plots to file
% PrintNum = integer -> selects how often to save plots (which iteration to
% save)
% Plot = true/false.  Set to true to dynamically plot solution


close all force;
clearvars -except fit options
warning('off', 'Control:analysis:MarginUnstable')

def = struct(...
        'mode','DCM', ...
        'L', 18e-6, ...
        'C', 4.7e-6, ...
        'R', 300, ...
        'Vo', 5.5, ...
        'Vs', 2.75, ...
        'Fs', 350e3, ...
        'Algorithm', 'GA', ...
        'PSOType', 'Constrict', ...
        'Iter', 20, ...
        'Size', 30, ...
        'Print', false, ...
        'PrintNum', 5, ...
        'Plot', true);

% Check number of input arguments
if ~nargin
    options = def;
else
    if ~isstruct(options)
        error('MATLAB:anneal:badOptions',...
            'Input argument ''options'' is not a structure')
    end
    params = {'mode', 'L', 'C', 'R', 'Vo', 'Vs', 'Fs', ...
              'Algorithm', 'PSOType', 'Iter', 'Size', ...
              'Print', 'PrintNum', 'Plot'};
    for nm = 1:length(params)
        if ~isfield(options,params{nm})
            options.(params{nm}) = def.(params{nm});
        end
    end
end

% Run either GA or PSO
if strcmpi(options.Algorithm, 'GA')
    fit.GA  = GA(options);
elseif strcmpi(options.Algorithm, 'PSO')
    fit.PSO = PSO(options);
elseif strcmpi(options.Algorithm, 'ALL')
    fit.GA  = GA(options);
    fit.PSO = PSO(options);
end



end








    