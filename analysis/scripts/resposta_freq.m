%% 4.6 Resposta em frequ[encia
clear; clc; close all;

%% Read the .csv
raw_data = readtable("..\sim_data\teste.csv", 'VariableNamingRule', 'preserve');

%% Plot
figure
set(gcf, 'Position',  [100, 100, 660, 340]);

ax = gca;
ax.FontSize = 11;
ax.TickLabelInterpreter = 'latex';

% plot semilog
semilogx(raw_data{:,1}, raw_data{:,2}, 'Color', [0 0 0], 'LineWidth', 1.5);
hold on;  % keep the current plot

% get maximum magnitude, its frequency, and bandwidth
[max_mag, max_freq, max_idx, fL, left_idx, fH, right_idx, bandwidth] = analyze_frequency_response(raw_data{:,1}, raw_data{:,2});

% plot desired frequencies and magnitudes
xline(fL, '--', 'Color', [0.01 0.24 0.33], 'LineWidth', 1.5);  % left -3dB frequency line
xline(fH, '--', 'Color', [0.01 0.24 0.33], 'LineWidth', 1.5);  % right -3dB frequency line
shade_region([fL fH],[-40 20], [0.01 0.24 0.33]);  % shaded region
plot(max_freq, max_mag, 's', 'MarkerSize', 8, 'MarkerFaceColor', [0.93 0.69 0.13], 'MarkerEdgeColor','none');
add_point_annotation(ax, raw_data, max_idx, -0.04, -0.015,'kHz', 'dB');
plot(fL, max_mag - 3, '.', 'MarkerSize', 20, 'Color', [0.01 0.24 0.33]);
add_point_annotation(ax, raw_data, left_idx, -0.16, -0.03,'Hz', 'dB');
plot(fH, max_mag - 3, '.', 'MarkerSize', 20, 'Color', [0.01 0.24 0.33]);
add_point_annotation(ax, raw_data, right_idx, 0.065, -0.029,'kHz', 'dB');


hold off;  % disable hold on

set(gca, 'YColor', [0 0 0])  % change left y-axis color to black
set_axis_labels(gca().YAxis(1), 'dB'); % add dB symbol to y-axis tick labels
grid on, grid minor;

% change axis tick labels size
ax = gca;
ax.FontSize = 11;
ax.TickLabelInterpreter = 'latex';

% x axis
xlim([0 1e8])
xticks = [1, 10, 100, 1e3, 1e4, 1e5 1e6 1e7 1e8];
xticklabels = {'1Hz', '10Hz', '100Hz', '1kHz', '10kHz', '100kHz', '1MHz', '10MHz', '100MHz'};
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);

%% Functions
% Adds a symbol to the y-axis tick labels
function set_axis_labels(axis, unit)
    axis.Exponent = 0;  % disable scientific notation
    tick_values = get(axis, 'TickValues');
    tick_labels = arrayfun(@(x)[num2str(x), unit], tick_values, 'UniformOutput', false);
    set(axis, 'TickLabels', tick_labels);
end

function [max_mag, max_freq, max_idx, fL, left_idx, fH, right_idx, bandwidth] = analyze_frequency_response(freq, mag)
    % Find max magnitude and its corresponding frequency
    [max_mag, max_idx] = max(mag);
    max_freq = freq(max_idx); % Max magnitude's frequency
    
    % Find the -3dB magnitude
    mag_3dB = max_mag - 3;
    
    % Find closest points to -3dB magnitude on the left and right of the peak
    [~, left_idx] = min(abs(mag(1:max_idx) - mag_3dB));
    [~, right_idx_temp] = min(abs(mag(max_idx:end) - mag_3dB));
    right_idx = right_idx_temp + max_idx - 1;

    fL = freq(left_idx);
    fH = freq(right_idx);

    % Calculate bandwidth
    bandwidth = freq(right_idx) - freq(left_idx);
end


% Creates a shaded region on the plot
function shade_region(x_range, y_range, color)
    patch('XData', [x_range(1), x_range(2), x_range(2), x_range(1)], ...
        'YData', [y_range(1), y_range(1), y_range(2), y_range(2)], ...
        'FaceColor', color, 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end

function add_point_annotation(ax, data, idx, offX, offY, x_unit, y_unit)
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
    if x_unit == "kHz"
        textStr = sprintf('(%.3f %s, %.3f %s)', dataArray(idx,1)/1000, x_unit, dataArray(idx,2), y_unit);
    else
        textStr = sprintf('(%.3f %s, %.3f %s)', dataArray(idx,1), x_unit, dataArray(idx,2), y_unit);
    end

    % ensure normalized coordinates are within [0, 1]
    normX = min(max(normX, 0), 1);
    normY = min(max(normY, 0), 1);

    % create annotation
    a = annotation('textbox', [axPos(1)+normX*axPos(3)+offX, axPos(2)+normY*axPos(4)+offY, 0.1, 0.1],...
        'String', textStr,...
        'FitBoxToText', 'on',...
        'BackgroundColor', 'none',...
        'EdgeColor', 'none',...
        'FontSize', 10,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle',...
        'Interpreter', 'latex');
end