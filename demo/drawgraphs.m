%    Copyright 2011 Nicolas Melot
%
%    Nicolas Melot (nicolas.melot@liu.se)
%
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% =============================================================================
%
%
%	Processes and plot the data collected, using all plotting primitives.
%	This parts takes parameters from the settings file.
%

%% Make sure Octave is not tempted to consider this file as a function file
1;

% Local row-per-row tranformation functions
function y = global_start(row, col)
	NSEC_IN_SEC = 1000000000;
	MSEC_IN_SEC = 1000;
	NSEC_IN_MSEC = NSEC_IN_SEC / MSEC_IN_SEC;
	y = (data(row, {'start time sec'}, 0) .* NSEC_IN_SEC + data(row, {'start time nsec'}, 0)) ./ NSEC_IN_MSEC;
end

function y = thread_start(row, col)
	NSEC_IN_SEC = 1000000000;
	MSEC_IN_SEC = 1000;
	NSEC_IN_MSEC = NSEC_IN_SEC / MSEC_IN_SEC;
	y = (data(row, {'thread start sec'}, 0) .* NSEC_IN_SEC + data(row, {'thread start nsec'}, 0)) ./ NSEC_IN_MSEC - global_start(row, 'unused');
end

function y = thread_stop(row, col)
	NSEC_IN_SEC = 1000000000;
	MSEC_IN_SEC = 1000;
	NSEC_IN_MSEC = NSEC_IN_SEC / MSEC_IN_SEC;
	y = (data(row, {'thread stop sec'}, 0) .* NSEC_IN_SEC + data(row, {'thread stop nsec'}, 0)) ./ NSEC_IN_MSEC - global_start(row, 'unused');
end

function y = cp_start(row, col)
	y = data(row, {'thread start'}, 0);
end
function y = cp_stop(row, col)
	y = data(row, {'thread stop'}, 0);
end
function y = set_thread_zero(row, col)
	y = 0;
end

% First part: filtering, selection and basic transformations
collected = select(table, {'entropy' 'nb threads' 'count' 'thread' 'start time sec' 'start time nsec' 'stop time sec' 'stop time nsec' 'thread start sec' 'thread start nsec' 'thread stop sec' 'thread stop nsec'}, 0); % Keep every columns except the try number.
collected = where(collected, 'nb threads >= nb threads::seq. & nb threads <= nb threads::8'); % Keeps only measurements involving sequential or 1, 2, 4 and 8 threads.
collected = duplicate(collected, {'stop time nsec' 'thread stop nsec'}, {'global time' 'thread time'}, 1); % Duplicate two columns. The new columns will be used to store the computed time difference between start and stop for both global and per-thread process.
collected = apply(collected, {'global time' 'thread time'}, {@time_difference_global, @time_difference_thread}, 0); % Compute the global start-stop difference
collected = select(collected, {'entropy' 'nb threads' 'count' 'thread' 'global time' 'thread time'}, 0); % keep every features (entropy, number of threads, number of jumps and thread number) plus the time differences calculated earlier.
collected = duplicate(collected, {'global time' 'thread time'}, {'global stddev' 'thread stddev'}, 2); % Create 2 more columns to calculate timing standard deviations

% Second part: extraction and reshaping to produce smaller matrices
% Global timings
global_timing = groupby(collected, {'entropy' 'nb threads' 'count'}, {'global time' 'thread time' 'global stddev' 'thread stddev'}, {@mean, @mean, @std, @std}); % Separate into groups defined by entropy, number of threads and number of loops
global_timing_04 = where(global_timing, 'entropy == 0.4'); % Select rows denoting experiments with an entropy of 0.1 and performing 200 million jumps.

% Timings per thread
thread_timing = groupby(collected, {'entropy' 'nb threads' 'count' 'thread'}, {'global time' 'thread time' 'global stddev' 'thread stddev'}, {@mean, @mean, @std, @std}); % Separate into groups defined by entropy, number of threads, number of loops and thread number.
thread_timing = extend(thread_timing, {'entropy' 'nb threads' 'count'}, {'thread'}, 0); % Extend groups that do not involve the maximum amount of threads and copy the thread number to each rows of extended groups. Fills the rest with 0 (non-existent threads work for a null period of time.
thread_timing_04 = where(thread_timing, 'entropy == 0.4'); % Select rows denoting experiments with an entropy of 0.1 and performing 200 million jumps.

% Gather start and stop time for global and each thread, target to a gantt diagram
% For the sake of demo with less structured and friendly processing, we keep only the maximal amount of threads and number of jumps, available in data
max_threads = max(data(select(table, {'nb threads'}, 0), {'nb threads'}, 0)); % Get maximum number of thread in this data
max_ct = max(data(select(table, {'count'}, 0), {'count'}, 0)); % Get maximum jump count from this data
gantt = where(table, ['nb threads == ' int2str(max_threads) ' & count == ' int2str(max_ct)]); % Actually select data for max amount of thread and jump count

gantt = duplicate(gantt, {'nb threads' 'nb threads'}, {'thread start' 'thread stop'}, -1); % Create new columns for start and stop values
gantt = setalias(gantt, {'thread start' 'thread stop'}, {{} {}}); % Make sure the two new columns copied from column thread do not get aliases that make no sens to them
gantt = apply(gantt, {'thread start' 'thread stop'}, {@thread_start, @thread_stop}, 0); % Apply conversion functions

gantt = select(gantt, {'entropy', 'try', 'thread', 'thread start' 'thread stop'}, 0); % eliminate nb threads and count columns
% Create a new lines for global time, in order to fit data shape to quickgantt function, with minimal starting time and maximal finishing time
globals = groupby(gantt, {'try'}, {'entropy', 'thread', 'thread start', 'thread stop'}, {@mean, @mean, @min, @max}); % Isolate data gather per try number and apply a mean to every other columns. We only care about try columns and global time values here. The rest is '@mean'ed' but we won't keep it. 
globals = apply(globals, {'thread' 'thread start' 'thread stop'}, {@set_thread_zero, @cp_start, @cp_stop}, 0); % Reset thread number to 0 (to denote global time) and copy columns for global timing to thread columns

gantt = insert(where(gantt, 'thread != thread::SEQ'), data(globals, {'entropy', 'try', 'thread', 'thread start', 'thread stop'}, 0)); % Insert this new data to the table. Lines of thread = 0 now denote global time.

% Compute thread (and global) start and stop time
gantt = groupby(gantt, {'thread'}, {'thread start' 'thread stop'}, {@mean, @mean}); % Group by thread number and reduce groups using mean function
thread = alias(gantt, {'thread'}){:};
thread_size = size(thread);
thread_size = thread_size(2);

%% Rename 'SEQ' to 'Global'
thread = {'Global' thread{2:thread_size}};
%thread = {thread{2:thread_size} 'Global'};
gantt = setalias(gantt, {'thread'}, {thread});

% Third part: use plotting function to generate graphs, format and store them in graphic files.
% /!\ Matlab requires three points ( ... ) at the end of lines to support line breaks in the middle of functions.
num = 1;
quickplot(num, ...
	global_timing_04, ... % Table to take data from
	'nb threads', ... % Column for x values
	{'global time', 'global time'}, ... % Columns for y values
	{'count == count::10^{8}' 'count == count::2 10^8'}, ... % Filters for columns mentioned earlier.
	{}, ... % Label to replace x values. Use raw values
	colors{num}, ... % Colors to be applied to the curves, written in RGB vector format
	markers{num}, ... % Enough markers for 6 curves. Browse the web to find more.
	thickness{num}, marker_size{num}, font{num}, font_size{num}, width{num}, height{num}, ... % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	'Number of threads', 'Time in milliseconds', 'Global time to perform 100 and 200 millions jumps in parallel', ... % Title of the graph, label of y axis and label of x axis.
	{'100m iteration, 0.4 entropy ' '200m iteration, 0.4 entropy '}, ... % Labels for curves
	legend_location{num}, legend_box{num}, [ output_prefix{num} int2str(num) '_' 'timing-error' '.' output_extension{num}], output_format{num}); % Layout of the legend, file to write the plot to and format of the output file

% The two following graphs are combined together
num = 2;
quickerrorbar(num, ...
	global_timing_04, ... % Plot global timings.
	'nb threads', ... % Column for x
	{'global time'}, ... % Columns for y (one curve per column)
	{'global stddev'}, ... % Columns for standard deviation
	{'count == count::10^{8}'}, ... % Filters for each curve to be plotted (100 million jumps only)
	{}, ... % Label to replace x values. Use raw values
	colors{num}, ... % Colors to be applied to the curves, written in RGB vector format
	markers{num}, ... % Enough markers for 6 curves. Browse the web to find more.
	marker_size{num}, thickness{num}, font{num}, font_size{num}, width{num}, height{num}, ... % Markers size, curves' thickness, Font name and font size, canvas' width and height
	'Number of threads', 'Time in milliseconds', 'Time per thread to perform 100 millions jumps in parallel', ... % Title of the graph, label of y axis and label of x axis.
	{'100m iteration, 0.4 entropy '}, ... % Labels for curves
	legend_location{num}, legend_box{num}, [ output_prefix{num} int2str(num) '_' 'timing-100' '.' output_extension{num}], output_format{num}); % Layout of the legend, file to write the plot to and format of the output file

%% This graph is combined with the preivous graph, it keeps the same number
quickbar(num, ...
	colsep(where(thread_timing_04, 'count == count::10^{8}'), 'nb threads', 'thread time', 0), ... % Plot global timings for 100 millions jumps only, thread by thread.
	'nb threads', ... % x values
	{'thread time', 'thread time 2', 'thread time 3', 'thread time 4', 'thread time 5', 'thread time 6', 'thread time 7', 'thread time 8'}, ... % Values for y, one column per bar
	'', ... % Data filter to apply before plotting (100 million jumps only)
	{}, ... % Label to replace x values. Use raw values
	'grouped', 0.5, ... % Style of the bars ('grouped' or 'stacked')
	'MgOpenModernaBold.ttf', 8, 800, 400, ... % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	'Number of threads', 'Time in milliseconds', 'Time per thread to perform 100 millions jumps in parallel', ... % Title of the graph, label of y axis and label of x axis.
	{'100m iteration, 0.4 entropy ' except(alias(table, {'thread'}){:}, {'SEQ'}){:}}, ... % Labels for curves of the previous graph and bars from this graph
	legend_location{num}, legend_box{num}, [ output_prefix{num} int2str(num) '_' 'timing-100' '.' output_extension{num}], output_format{num}); % Layout of the legend, file to write the plot to and format of the output file

%% Now we want seq. to be at the end of the plot
global_timing_04 = shuffle(global_timing_04, {'nb threads'}, {{'2' '3' '4' '5' '6' '7' '8' 'over.' 'seq.'}});
thread_timing_04 = shuffle(thread_timing_04, {'nb threads'}, {{'2' '3' '4' '5' '6' '7' '8' 'over.' 'seq.'}});

% The two following graphs are combined together
num = 3;
quickerrorbar(3,
	global_timing_04, ... % Plot global timings.
	'nb threads', ... % Column for x
	{'global time'}, ... % Columns for y (one curve per column)
	{'global stddev'}, ... % Columns for standard deviation
	{'count == count::2 10^8'}, ... % Filters for each curve to be plotted (100 million jumps only)
	{}, ... % Label to replace x values. Use raw values
	colors{num}, ... % Colors to be applied to the curves, written in RGB vector format
	markers{num}, ... % Enough markers for 6 curves. Browse the web to find more.
	marker_size{num}, thickness{num}, font{num}, font_size{num}, width{num}, height{num}, ... % Markers size, curves' thickness, Font name and font size, canvas' width and height
	'Number of threads', 'Time in milliseconds', 'Time per thread to perform 200 millions jumps in parallel', ... % Title of the graph, label of y axis and label of x axis.
	{'100m iteration, 0.4 entropy '}, ... % Labels for curves
	legend_location{num}, legend_box{num}, [ output_prefix{num} int2str(num) '_' 'timing-200' '.' output_extension{num}], output_format{num}); % Layout of the legend, file to write the plot to and format of the output file

quickbar(num,
	colsep(where(thread_timing_04, 'count == count::2 10^8'), 'nb threads', 'thread time', 0), ... % Plot global timings for 100 millions jumps only, thread by thread.
	'nb threads', ... % x values
	{'thread time', 'thread time 2', 'thread time 3', 'thread time 4', 'thread time 5', 'thread time 6', 'thread time 7', 'thread time 8'}, ... % Values for y, one column per bar
	'', ... % Data filter to apply before plotting (100 million jumps only)
	{}, ... % Label to replace x values. Use raw values
	'grouped', 0.5, ... % Style of the bars ('grouped' or 'stacked')
	'MgOpenModernaBold.ttf', 8, 800, 400, ... % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	'Number of threads', 'Time in milliseconds', 'Time per thread to perform 200 millions jumps in parallel', ... % Title of the graph, label of y axis and label of x axis.
	{'200m iteration, 0.4 entropy ' except(alias(table, {'thread'}){:}, {'SEQ'}){:}}, ... % Labels for curves of the previous graph and bars from this graph
	legend_location{num}, legend_box{num}, [ output_prefix{num} int2str(num) '_' 'timing-200' '.' output_extension{num}], output_format{num}); % Layout of the legend, file to write the plot to and format of the output file

% Separate graph for task gantt representation
%% We want the global line to be at the top
gantt = shuffle(gantt, {'thread'}, {{'Thread 1' 'Thread 2' 'Thread 3' 'Thread 4' 'Thread 5' 'Thread 6' 'Thread 7' 'Thread 8' 'Global'}});

num=4;
quickgantt(num, ... % figure number id
	colmerge(gantt, 'thread', {{'thread start'} {'thread stop'}}, {'start' 'stop'}), ... % data to be plot; this is useless as each column created takes only one source
	'thread', ... % Gantt actors
	'start', ... % Start values for lines for each actor
	'stop', ... % Stop values for lines for each actor
	colors{num}, ... % colors
	hatch_thickness{num}, ... % thickness
	hatch_pattern{num}, ... % hatch pattern,
	hatches{num}, ... % hatch line style
	hatch_colors{num}, % Colors to be applied to the curves, written in RGB vector format
	pattern_thickness{num}, pattern_space{num}, ... % patterns, patternd
	font{num}, font_size{num}, ... % fontname, font size
	width{num}, height{num}, ... % respectively: canvas width and height
	'Time in milliseconds', 'Thread', ['Thread spawn and join accross time'], ... % x axis, y axis, graph title, 
	[ output_prefix{num} int2str(num) '_' 'gantt' '.' output_extension{num} ], output_format{num}); % File to write the plot to and format of the output file
