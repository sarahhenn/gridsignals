function [Ti,Prad,PhiG,Ta,Papp,n_air,n_inf,Pvent] = importSimulationResultsJerome(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [TI,PRAD,PHIG,TA,PAPP,N_AIR,N_INF] = IMPORTFILE(FILENAME) Reads data
%   from text file FILENAME for the default selection.
%
%   [TI,PRAD,PHIG,TA,PAPP,N_AIR,N_INF] = IMPORTFILE(FILENAME, STARTROW,
%   ENDROW) Reads data from rows STARTROW through ENDROW of text file
%   FILENAME.
%
% Example:
%   [Ti,Prad,PhiG,Ta,Papp,n_air,n_inf] = importfile('results_RT2005_Constant.csv',1, 105120);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2018/06/05 15:54:07

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Format for each line of text:
%   column2: double (%f)
%	column3: double (%f)
%   column4: double (%f)
%	column5: double (%f)
%   column6: double (%f)
%	column7: double (%f)
%   column8: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*s%f%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
Ti = dataArray{:, 1};
Prad = dataArray{:, 2};
PhiG = dataArray{:, 3};
Ta = dataArray{:, 4};
Papp = dataArray{:, 5};
n_air = dataArray{:, 6};
n_inf = dataArray{:, 7};

n_inf(isnan(n_inf))=0;
rho_air=1.2;
C_air=1005;
Pvent=(n_air+n_inf)*rho_air*C_air.*(Ta-Ti);

