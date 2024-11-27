% Traffic Simulation with Congestion Prioritization
clc;
clear;

% Parameters
num_lanes = 4; % Number of lanes
simulation_time = 300; % Total simulation time (seconds)
arrival_rates = [12000, 14000, 13000, 11000]; % Vehicles arriving per hour per lane
queues = zeros(1, num_lanes); % Initialize vehicle queues
total_cycle_time = 120; % Total signal cycle time (seconds)
queue_threshold = 300; % Congestion threshold
cumulative_arrivals = zeros(1, num_lanes); % Track cumulative arrivals
cumulative_processed = zeros(1, num_lanes); % Track cumulative processed vehicles

% Function to optimize green light durations
function green_durations = optimize_signal(queues, total_cycle_time, queue_threshold)
    num_lanes = length(queues);

    % Adjust weights for congested lanes
    weights = ones(1, num_lanes);
    weights(queues > queue_threshold) = 2; % Prioritize congested lanes

    % Objective function: Penalize unprocessed queues
    objective = @(durations) sum(weights .* (queues ./ max(durations / 2, 1)).^2);

    % Constraints: Total green light time and min/max duration per lane
    Aeq = ones(1, num_lanes); % Sum of green light durations must equal total_cycle_time
    beq = total_cycle_time;
    lb = ones(1, num_lanes) * 30; % Minimum 30 seconds per lane
    ub = ones(1, num_lanes) * 60; % Maximum 60 seconds per lane

    % Initial guess: Equal duration for all lanes
    initial_guess = ones(1, num_lanes) * (total_cycle_time / num_lanes);

    % Solve optimization problem
    options = optimoptions('fmincon', 'Display', 'none'); % Suppress output
    green_durations = fmincon(objective, initial_guess, [], [], Aeq, beq, lb, ub, [], options);
end

% Simulation Loop
figure; % Create a figure for the bar graph
average_queues = zeros(simulation_time, 1); % Track average queue size over time
for t = 1:simulation_time
    % Update vehicle arrivals and queues
    for lane = 1:num_lanes
        arrivals = poissrnd(arrival_rates(lane) / 3600); % Random arrivals per second
        queues(lane) = queues(lane) + arrivals;
        cumulative_arrivals(lane) = cumulative_arrivals(lane) + arrivals; % Track cumulative arrivals
    end

    % Optimize green light durations
    green_light_durations = optimize_signal(queues, total_cycle_time, queue_threshold);

    % Process vehicles based on green light durations
    for lane = 1:num_lanes
        if queues(lane) > queue_threshold
            processed_vehicles = min(queues(lane), green_light_durations(lane) * 0.3); % Faster processing
        else
            processed_vehicles = min(queues(lane), green_light_durations(lane) * 0.1); % Default processing
        end
        queues(lane) = queues(lane) - processed_vehicles;
        cumulative_processed(lane) = cumulative_processed(lane) + processed_vehicles; % Track processed vehicles
    end

    % Ensure queues are non-negative
    queues = max(queues, 0);

    % Compute average queue size
    average_queues(t) = mean(queues);

    % Debugging: Print statistics
    fprintf('Time: %d, Queues: %s\n', t, mat2str(queues));
    fprintf('Cumulative Arrivals: %s\n', mat2str(cumulative_arrivals));
    fprintf('Cumulative Processed: %s\n', mat2str(cumulative_processed));
    fprintf('Average Queue Size: %.2f\n', average_queues(t));

    % Color-coded bar plot based on queue size
    colors = zeros(num_lanes, 3); % Initialize RGB colors
    for lane = 1:num_lanes
        if queues(lane) > 1500
            colors(lane, :) = [1, 0, 0]; % Red for high traffic
        elseif queues(lane) > 500
            colors(lane, :) = [1, 1, 0]; % Yellow for moderate traffic
        else
            colors(lane, :) = [0, 0.5, 0]; % Green for low traffic
        end
    end

    % Plot the queues with color-coding
    bar_plot = bar(queues, 'FaceColor', 'flat'); % Use 'flat' to enable color-coding
    bar_plot.CData = colors; % Apply colors to each bar

    xlabel('Lane');
    ylabel('Vehicles in Queue');
    title(sprintf('Traffic Queues at Time %d s', t));
    ylim([0, max(queues) + 100]); % Adjust dynamic Y-axis scaling
    pause(0.1); % Pause for visualization update
end

% Plot average queue size trend
figure;
plot(1:simulation_time, average_queues);
xlabel('Time (s)');
ylabel('Average Queue Size');
title('Average Queue Size Over Time');

% Post-Simulation Analysis
fprintf('Final Statistics:\n');
fprintf('Average Queue Size: %.2f\n', mean(average_queues));
fprintf('Total Arrivals per Lane: %s\n', mat2str(cumulative_arrivals));
fprintf('Total Processed per Lane: %s\n', mat2str(cumulative_processed));
