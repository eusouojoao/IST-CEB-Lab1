%% 4.4 Tensões vs(t), vin(t), vo1(t) e vout(t) e 4.5 Zonas de funcionamento do transístor Q1
clear; clc; close all;

% Read the .csv
raw_data1 = readtable("..\sim_data\4_4-total.csv", 'VariableNamingRule', 'preserve');
raw_data2 = readtable("..\sim_data\4_5-total.csv", 'VariableNamingRule', 'preserve');

% call the functions that handle the plots
plot_4_4(raw_data1);
plot_4_5(raw_data2);

%% Functions
% Tensões vs(t), vin(t), vo1(t) e vout(t)
function plot_4_4(data)
    t = data{:,1} * 1000;

    % Vs and Vin
    figure
    set(gcf, 'Position',  [100, 100, 660, 340]);
    % plots
    plot(t, data{:,4}, 'Color', [0.01 0.24 0.33], 'LineWidth', 1.5); hold on;
    plot(t, data{:,2}, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5); hold off;
    grid on, grid minor;
    legend('$v_{S}$','$v_{in}$','FontSize', 16, 'Interpreter', 'latex');
    % customise axis labels
    ax = gca;
    ax.FontSize = 11;
    ax.TickLabelInterpreter = 'latex';
    set_axis_labels(gca().YAxis, 'V');
    set_axis_labels(gca().XAxis, 'ms');

    % Vo1 and Vout
    figure
    set(gcf, 'Position',  [100, 100, 660, 340]);
    ax = gca;
    ax.FontSize = 11;
    ax.TickLabelInterpreter = 'latex';
    % plots
    plot(t, data{:,3}, 'Color', [0.1, 0.4, 0.4], 'LineWidth', 1.5); hold on;
    plot(t, data{:,5}, 'Color', [0.8, 0.4, 0.0], 'LineWidth', 1.5); hold off;
    grid on, grid minor;
    legend('$v_{O1}$', '$v_{out}$', 'FontSize', 16, 'Interpreter', 'latex');
    % customise axis labels
    ax = gca;
    ax.FontSize = 11;
    ax.TickLabelInterpreter = 'latex';
    set_axis_labels(gca().YAxis, 'V');
    set_axis_labels(gca().XAxis, 'ms');
end

% Zonas de funcionamento do transístor Q1
function plot_4_5(data)
    figure
    set(gcf, 'Position',  [100, 100, 660, 390]);

    t = data{:,1} * 1000; 
    plot(t, data{:,3}, 'Color', [0.01 0.24 0.33], 'LineWidth', 1.5); hold on;
    plot(t, data{:,2}, 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5); hold on;
    plot(t, data{:,4}, 'Color', [0.93 0.69 0.13], 'LineWidth', 1.5); hold off;
    grid on, grid minor;
    legend('$v_\textit{O1}$', '$v_\textit{CE1}$',  '$v_\textit{S}$', 'FontSize', 16, ...
        'Interpreter', 'latex', 'Orientation','horizontal','Location','northoutside');

    xlim([0 1]);
    % customise axis labels
    ax = gca;
    ax.FontSize = 11;
    ax.TickLabelInterpreter = 'latex';
    set_axis_labels(gca().YAxis, 'V');
    set_axis_labels(gca().XAxis, 'ms');

    % specify the three regions
    shade_region([0.305, 0.425], [-1, 5], [1 0 0], '\textbf{Corte}', 0, 0.6);
    shade_region([0.425, 0.545], [-1, 5], [0 1 0], '\textbf{ZAD}', 0.003, 0.6);
    shade_region([0.545, 0.69], [-1, 5], [0 0 1], '\textbf{Satura\c{c}\~ao}', 0, 0.6);
end

% Adds a symbol to the y-axis tick labels
function set_axis_labels(axis, unit)
    axis.Exponent = 0;  % disable scientific notation
    tick_values = get(axis, 'TickValues');
    tick_labels = arrayfun(@(x)[num2str(x), unit], tick_values, 'UniformOutput', false);
    set(axis, 'TickLabels', tick_labels);
end

% Creates a shaded region on the plot
function shade_region(x_range, y_range, color, label, x_off, y_off)
    patch('XData', [x_range(1), x_range(2), x_range(2), x_range(1)], ...
        'YData', [y_range(1), y_range(1), y_range(2), y_range(2)], ...
        'FaceColor', color, 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    t = text(mean(x_range)+x_off, mean(y_range)+y_off, label, 'HorizontalAlignment', 'center', ...
             'Interpreter', 'latex', 'Color', color*0.5, 'FontSize', 14, 'Rotation', 48);
    uistack(t, 'top');  % bring text to top
end