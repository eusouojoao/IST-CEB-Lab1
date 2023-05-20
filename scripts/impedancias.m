%% 4.2 Análise AC: Determinação das impedâncias de entrada Ri1 e Ri2
clear; clc; close all;

%% Read the .csv
raw_data = readtable("..\sim_data\4_2-Ri1.csv", 'VariableNamingRule', 'preserve');

%% Convert dB to linear and to kilo units
linear = db2mag(raw_data{:,2}) / 1000;

%% Plot
figure
set(gcf, 'Position',  [100, 100, 660, 340]);
grid on, grid minor;

% change axis tick labels size
ax = gca;
ax.FontSize = 11;
ax.TickLabelInterpreter = 'latex';

% x-axis
xlim([1 1e6])
% set x-axis tick locations and labels
xticks = [1, 10, 100, 1e3, 1e4, 1e5 1e6];
xticklabels = {'1Hz', '10Hz', '100Hz', '1kHz', '10kHz', '100kHz', '1MHz'};
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);

% left side
yyaxis left; 
semilogx(raw_data{:,1}, linear, 'Color', [0 0 0], 'LineWidth', 1.5); hold on;
set(gca, 'YColor', [0 0 0])  % change left y-axis color to black
set_axis_labels(gca().YAxis(1), 'k$\Omega$'); % add kilo-ohm symbol to y-axis tick labels
% find closest frequency to 16922 Hz
[~, idx] = min(abs(raw_data{:,1} - 16922));
plot(raw_data{idx,1}, linear(idx), 's', 'MarkerSize', 8, ...
    'MarkerFaceColor', [0.93 0.69 0.13], 'MarkerEdgeColor','none'); hold off;
add_point_annotation(ax, raw_data, idx, 'kHz', 'k$\Omega$');

% right side
yyaxis right; 
semilogx(raw_data{:,1}, raw_data{:,3}, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.5);
set(gca, 'YColor', [0.1 0.1 0.1])  % change right y-axis color to gray
set_axis_labels(gca().YAxis(2), '$^\circ$'); % add degree symbol to y-axis tick labels

%% Functions
% Adds a symbol to the y-axis tick labels
function set_axis_labels(axis, unit)
    axis.Exponent = 0;  % disable scientific notation
    tick_values = get(axis, 'TickValues');
    tick_labels = arrayfun(@(x)[num2str(x), unit], tick_values, 'UniformOutput', false);
    set(axis, 'TickLabels', tick_labels);
end

function add_point_annotation(ax, data, idx, x_unit, y_unit)
    % convert the table to array
    dataArray = table2array(data);

    % get axes position in normalized units
    axPos = ax.Position;

    % get the axis limits
    ax_xlim = xlim(ax);
    ax_ylim = ylim(ax);

    % convert the data point location to normalized figure coordinates
    if ax.XScale == "log"
        normX = (log10(dataArray(idx,1)) - log10(ax_xlim(1))) / (log10(ax_xlim(2)) - log10(ax_xlim(1)));
    else
        normX = (dataArray(idx,1) - ax_xlim(1)) / (ax_xlim(2) - ax_xlim(1));
    end
    normY = (dataArray(idx,2) - ax_ylim(1)) / (ax_ylim(2) - ax_ylim(1));

    % define text string with frequency and magnitude
    textStr = sprintf('(%.3f %s, %.3f %s)', dataArray(idx,1)/1000, x_unit, db2mag(dataArray(idx,2)) / 1000, y_unit);

    % ensure normalized coordinates are within [0, 1]
    normX = min(max(normX, 0), 1);
    normY = min(max(normY, 0), 1);

    % create annotation
    a = annotation('textbox', [axPos(1)+normX*axPos(3)-0.066, axPos(2)+normY*axPos(4)-0.297, 0.1, 0.1],...
        'String', textStr,...
        'FitBoxToText', 'on',...
        'BackgroundColor', 'none',...
        'EdgeColor', 'none',...
        'FontSize', 10,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle',...
        'Interpreter', 'latex');
end