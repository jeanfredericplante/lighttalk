% this is in support for the Light talk app
% decodes csv files with [timestamp, index, brightness, delta]
% should analyse how to output the proper message


%% Read the csv file
clear all, close all
reading_file = "lt_12.06.16 11.59.39_multiple_l_240ms.csv"

% analyze data
raw_csv = csvread(reading_file);

time_vector = raw_csv(2:end,1);
time_vector = time_vector - time_vector(1);
brightness = raw_csv(2:end, 3);
delta = raw_csv(2:end, 4);


% zoom
should_zoom = true
if should_zoom
    t_min = 1;
    t_max = 5;
    idx = find(time_vector > t_min & time_vector > t_max);
else
    idx = 1:size(time_vector,1);
end


% plots
figure('Name','Brightness and delta')
subplot(211)
plot(time_vector(idx), brightness(idx)); grid
title('Brightness')

subplot(212)
plot(time_vector(idx), delta(idx)); grid
title('Delta')
xlabel('time ms')
