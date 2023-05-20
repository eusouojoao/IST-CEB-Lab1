clear; clc; close all;

%% Import the data from the LTspice .raw file
raw_data = LTspice2Matlab('..\sim_data\data_AC.raw');

%% Extract the desired data
freq = raw_data.freq_vect;

% Find the indices of the variables [top/bot]
index_top = find(strcmp(raw_data.variable_name_list, 'V(vout)'));
index_bot = find(strcmp(raw_data.variable_name_list, 'V(vs)'));

% Convert complex data to magnitude (dB) and angle (degrees)
complex_data = raw_data.variable_mat(index_top,:) ./ raw_data.variable_mat(index_bot,:);
magnitude = 20*log10(abs(complex_data));
angle = angle(complex_data)*180/pi;
angle = unwrap(angle*pi/180)*180/pi; % avoid phase wrapping

% Create a table from the data (must be transposed)
T = table(freq', magnitude', angle');
T.Properties.VariableNames = {'Freq', 'Magnitude_dB', 'Angle_deg'};

%% Write the table to a .csv file
writetable(T, '..\sim_data\Av.csv');