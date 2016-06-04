%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: /home/vemu/Downloads/WindData 2014 - Mean.xlsx
%    Worksheet: January-June
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

function Netload = load_data(path,sheet)
%% Import the data
[~, ~, raw] = xlsread(path,sheet);
raw = raw(2:end,2);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
Netload = reshape([raw{:}],size(raw));

%% Clear temporary variables
clearvars raw R;
