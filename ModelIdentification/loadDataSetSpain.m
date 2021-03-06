function [Ta,Ti,PhiG,Prad,Pvent,Papp] = importResultsSpain(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE Import data from a spreadsheet
%   [Ta,Ti,Irradiation,PhiG,ThermalDemand,Prad] = IMPORTFILE(FILE) reads
%   data from the first worksheet in the Microsoft Excel spreadsheet file
%   named FILE and returns the data as column vectors.
%
%   [Ta,Ti,Irradiation,PhiG,ThermalDemand,Prad] = IMPORTFILE(FILE,SHEET)
%   reads from the specified worksheet.
%
%   [Ta,Ti,Irradiation,PhiG,ThermalDemand,Prad] =
%   IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from the specified
%   worksheet for the specified row interval(s). Specify STARTROW and
%   ENDROW as a pair of scalars or vectors of matching size for
%   dis-contiguous row intervals. To read to the end of the file specify an
%   ENDROW of inf.
%
%	Non-numeric cells are replaced with: NaN
%
% Example:
%   [Ta,Ti,Irradiation,PhiG,ThermalDemand,Prad] = importfile('data_RC_model_COOLING.XLSX','data_RC_model_COOLING',1,8931);
%
%   See also XLSREAD.

% Auto-generated by MATLAB on 2018/06/25 15:44:09

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 3;
    endRow = 2+12*24*365;
end

%% Import the data
[~, ~, raw] = xlsread(workbookFile, sheetName, sprintf('C%d:H%d',startRow(1),endRow(1)));
for block=2:length(startRow)
    [~, ~, tmpRawBlock] = xlsread(workbookFile, sheetName, sprintf('C%d:H%d',startRow(block),endRow(block)));
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
I = cellfun(@(x) ischar(x), raw);
raw(I) = {NaN};
data = reshape([raw{:}],size(raw));
data(isnan(data(:,1)),:)=[];

%% Allocate imported array to column variable names
Ta = data(:,1);
Ti = data(:,2);
PhiG = data(:,4)*1000;
Prad = data(:,6)*1000;
Pvent=zeros(size(Prad));
Papp=zeros(size(Prad));

