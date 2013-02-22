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
%	Load, transform and plot the data collected through experiments, using
%	All data manipulation functions as well as custom functions. This script
%	is very dense regarding the meaning of all statements and parameters. Be
%	very carefull when modifying or writing such a file as errors may be tiny
%	but have drastic conseauences and are difficult to track.
%	

% Local row-per-row tranformation functions
function y = global_start(row, col)
	NSEC_IN_SEC = 1000000000;
	MSEC_IN_SEC = 1000;
	NSEC_IN_MSEC = NSEC_IN_SEC / MSEC_IN_SEC;
	y = (data(row, {'start_time_sec'}, 0) .* NSEC_IN_SEC + data(row, {'start_time_nsec'}, 0)) ./ NSEC_IN_MSEC;
end

function y = thread_start(row, col)
	NSEC_IN_SEC = 1000000000;
	MSEC_IN_SEC = 1000;
	NSEC_IN_MSEC = NSEC_IN_SEC / MSEC_IN_SEC;
	y = (data(row, {'thread_start_sec'}, 0) .* NSEC_IN_SEC + data(row, {'thread_start_nsec'}, 0)) ./ NSEC_IN_MSEC - global_start(row, 'unused');
end

function y = thread_stop(row, col)
	NSEC_IN_SEC = 1000000000;
	MSEC_IN_SEC = 1000;
	NSEC_IN_MSEC = NSEC_IN_SEC / MSEC_IN_SEC;
	y = (data(row, {'thread_stop_sec'}, 0) .* NSEC_IN_SEC + data(row, {'thread_stop_nsec'}, 0)) ./ NSEC_IN_MSEC - global_start(row, 'unused');
end

function y = cp_start_sec(row, col)
	y = data(row, {'start_time_sec'}, 0);
end
function y = cp_start_nsec(row, col)
	y = data(row, {'start_time_nsec'}, 0);
end
function y = cp_stop_sec(row, col)
	y = data(row, {'stop_time_sec'}, 0);
end
function y = cp_stop_nsec(row, col)
	y = data(row, {'stop_time_nsec'}, 0);
end
function y = set_thread_zero(row, col)
	y = 0;
end

% First part: filtering, selection and basic transformations
collected = select(table, {'entropy' 'nb_threads' 'ct' 'thread' 'start_time_sec' 'start_time_nsec' 'stop_time_sec' 'stop_time_nsec' 'thread_start_sec' 'thread_start_nsec' 'thread_stop_sec' 'thread_stop_nsec'}, 0); % Keep every columns except the try number.
collected = where(collected, {'nb_threads'}, {[0 1 2 3 4 5 6 7 8]}); % Keeps only measurements involving sequential or 1, 2, 4 and 8 threads.
%collected = duplicate(collected, [1 1 1 1 1 1 1 2 1 1 1 2]); % Duplicate two columns. The new columns will be used to store the computed time difference between start and stop for both global and per-thread process.
collected = duplicate(collected, {'stop_time_nsec' 'thread_stop_nsec'}, {'global_time' 'thread_time'}, 1); % Duplicate two columns. The new columns will be used to store the computed time difference between start and stop for both global and per-thread process.
collected = apply(collected, {'global_time' 'thread_time'}, {@time_difference_global, @time_difference_thread}, 0); % Compute the global start-stop difference
collected = select(collected, {'entropy' 'nb_threads' 'ct' 'thread' 'global_time' 'thread_time'}, 0); % keep every features (entropy, number of threads, number of jumps and thread number) plus the time differences calculated earlier.
collected = duplicate(collected, {'global_time' 'thread_time'}, {'global_stddev' 'thread_stddev'}, 2); % Create 2 more columns to calculate timing standard deviations
% Second part: extraction and reshaping to produce smaller matrices
% Global timings
global_timing = groupby(collected, {'entropy' 'nb_threads' 'ct'}, {'global_time' 'thread_time' 'global_stddev' 'thread_stddev'}, {@mean, @mean, @std, @std}); % Separate into groups defined by entropy, number of threads and number of loops
global_timing_100 = where(global_timing, {'entropy' 'ct'}, {[0.4] [100000000]}); % Select rows denoting experiments with an entropy of 0.1 and performing 100 million jumps.
global_timing_200 = where(global_timing, {'entropy' 'ct'}, {[0.4] [200000000]}); % Select rows denoting experiments with an entropy of 0.1 and performing 200 million jumps.

% Timings per thread
thread_timing = groupby(collected, {'entropy' 'nb_threads' 'ct' 'thread'}, {'global_time' 'thread_time' 'global_stddev' 'thread_stddev'}, {@mean, @mean, @std, @std}); % Separate into groups defined by entropy, number of threads, number of loops and thread number.
thread_timing = extend(thread_timing, {'entropy' 'nb_threads' 'ct'}, {'thread'}, 0); % Extend groups that do not involve the maximum amount of threads and copy the thread number to each rows of extended groups. Fills the rest with 0 (non-existent threads work for a null period of time.
thread_timing_100 = where(thread_timing, {'entropy' 'ct'}, {[0.4] [100000000]}); % Select rows denoting experiments with an entropy of 0.1 and performing 100 million jumps.
thread_timing_200 = where(thread_timing, {'entropy' 'ct'}, {[0.4] [200000000]}); % Select rows denoting experiments with an entropy of 0.1 and performing 200 million jumps.

% Gather start and stop time for global and each thread, target to a gantt diagram
max_threads = max(data(select(table, {'nb_threads'}, 0), {'nb_threads'}, 0)); % Get maximum number of thread in this data
max_ct = max(data(select(table, {'ct'}, 0), {'ct'}, 0)); % Get maximum jump count from this data
table = where(table, {'nb_threads' 'ct'}, {[max_threads] [max_ct]}); % Actually select data for max amount of thread and jump count
table = select(table, {'entropy', 'try', 'thread', 'start_time_sec', 'start_time_nsec', 'stop_time_sec', 'stop_time_nsec', 'thread_start_sec', 'thread_start_nsec', 'thread_stop_sec', 'thread_stop_nsec'}, 0); % eliminate nb_threads and ct columns

% Create new lines for global time, in order to fit data shape to quickgantt function
globals = groupby(table, {'try'}, {'entropy', 'try', 'thread', 'start_time_sec', 'start_time_nsec', 'stop_time_sec', 'stop_time_nsec', 'thread_start_sec', 'thread_start_nsec', 'thread_stop_sec', 'thread_stop_nsec'}, {@mean, @mean, @mean, @mean, @mean, @mean, @mean, @mean, @mean, @mean, @mean}); % Isolate data gather per try number and apply a mean to every other columns. We only care about try columns and global time values here. The rest is "@mean'ed" but we won't keep it. 
globals = apply(globals, {'thread' 'thread_start_sec' 'thread_start_nsec' 'thread_stop_sec' 'thread_stop_nsec'}, {@set_thread_zero, @cp_start_sec, @cp_start_nsec, @cp_stop_sec, @cp_stop_nsec}, 0); % Reset thread number to 0 (to denote global time) and copy columns for global timing to thread columns
table = insert(table, data(globals, {'entropy', 'try', 'thread', 'start_time_sec', 'start_time_nsec', 'stop_time_sec', 'stop_time_nsec', 'thread_start_sec', 'thread_start_nsec', 'thread_stop_sec', 'thread_stop_nsec'}, 0)); % Insert this new data to the table. Lines of thread = 0 now denote global time.
% Sort data so the newly inserted lines for thread 0 take position next to the relevant line for thread 1, instead of undefined position after insert operation
matrix = data(table, {'entropy', 'try', 'thread', 'start_time_sec', 'start_time_nsec', 'stop_time_sec', 'stop_time_nsec', 'thread_start_sec', 'thread_start_nsec', 'thread_stop_sec', 'thread_stop_nsec'}, 0); % Get data matrix out
matrix = sortrows(matrix, 3); % Sort it along thread number: fits thread 0 line before every thread 1 line
matrix = sortrows(matrix, 2); % Sort it back along try column to get back into original order
table = setd(table, matrix); % Put matrix back into table

% Compute thread (and global) start and stop time
table = duplicate(table, {'none' 'none'}, {'thread_start' 'thread_stop'}, -1); % Create new columns for start and stop values
table = apply(table, {'thread_start' 'thread_stop'}, {@thread_start, @thread_stop}, 0); % Apply conversion functions
table = groupby(table, {'thread'}, {'thread_start' 'thread_stop'}, {@mean, @mean}); % Group by thread number and reduce groups using mean function
% Split every line into an inpendant line and put them in a cell so we can fit format for quickgantt (the reason is lines must be same length in matrices, but gantt needs different lines of different length).
matrix = data(table, {'thread_start' 'thread_stop'}, 0); % Extracts thread_start and thread_stop columns from matrix
msize = size(matrix); % Gets matrix' size
msize = msize(1); % Gets Matrix' number of lines
cell = {}; % Initialize a cell
for i = 1:msize
	cell{i} = matrix(i, :); % Add a matrix's line to the cell
end

% Third part: use plotting function to generate graphs, format and store them in graphic files.
% /!\ Matlab does not support line breaks in the middle of function calls. If you use Matlab, remove the comments and write the function call to quickplot, quickerrorbar and and quickbar in one line only.
quickplot(1,
	{global_timing_100 global_timing_200}, % Plot global timings for 100 millions and 200 millions jumps.
	'nb_threads', 'global_time', % column for x values then for y values
	{[1 0 0] [1 0 1] [0 0 1] [0 0 0] [0 0.5 0.5]}, % Colors to be applied to the curves, written in RGB vector format
	{"o" "^" "." "x" ">" "<"}, % Enough markers for 6 curves. Browse the web to find more.
	2, 15, "MgOpenModernaBold.ttf", 25, 800, 400, % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	"Number of threads", "Time in milliseconds", "Global time to perform 100 and 200 millions jumps in parallel", % Title of the graph, label of y axis and label of x axis.
	{"100m iteration, 0.1 entropy " "200m iteration, 0.01 entropy " "100m iteration, 0.00001 entropy " "300m iteration, 0.00001 entropy " }, % Labels for curves
	"northeast", "timing-error.eps", "epsc"); % Layout of the legend, file to write the plot to and format of the output file

% The two following graphs are combined together
quickerrorbar(2,
	{global_timing_100}, % Plot global timings for 100 millions jumps only.
	'nb_threads', 'global_time', 'global_stddev', % column for x values then for y values and standard deviation (error bars)
	{[1 0 0] [1 0 1] [0 0 1] [0 0 0] [0 0.5 0.5]}, % Colors to be applied to the curves, written in RGB vector format
	{"o" "^" "." "x" ">" "<"}, % Enough markers for 6 curves. Browse the web to find more.
	2, 15, "MgOpenModernaBold.ttf", 25, 800, 400, % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	"Number of threads", "Time in milliseconds", "Time per thread to perform 100 millions jumps in parallel", % Title of the graph, label of y axis and label of x axis.
	{"100m iteration, 0.1 entropy "}, % Labels for curves
	"northeast", "timing-100.eps", "epsc"); % Layout of the legend, file to write the plot to and format of the output file

quickbar(2,
	thread_timing_100, % Plot global timings for 100 millions jumps only, thread by thread.
	'nb_threads', 'thread_time', -1, % column for x values then for y values and base
	"grouped", 0.5, % Style of the bars ("grouped" or "stacked")
	"MgOpenModernaBold.ttf", 25, 800, 400, % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	"Number of threads", "Time in milliseconds", "Time per thread to perform 100 millions jumps in parallel", % Title of the graph, label of y axis and label of x axis.
	{"100m iteration, 0.1 entropy " "thread 1 " "thread 2 " "thread 3 " "thread 4 " "thread 5 " "thread 6 " "thread 7 " "thread 8 "}, % Labels for curves of the previous graph and bars from this graph
	"northeast", "timing-100.eps", "epsc"); % Layout of the legend, file to write the plot to and format of the output file

% The two following graphs are combined together
quickerrorbar(3,
	{global_timing_200}, % Plot global timings for 100 millions jumps only.
	'nb_threads', 'global_time', 'global_stddev', % column for x values then for y values and standard deviation (error bars)
	{[1 0 0] [1 0 1] [0 0 1] [0 0 0] [0 0.5 0.5]}, % Colors to be applied to the curves, written in RGB vector format
	{"o" "^" "." "x" ">" "<"}, % Enough markers for 6 curves. Browse the web to find more.
	2, 15, "MgOpenModernaBold.ttf", 25, 800, 400, % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	"Number of threads", "Time in milliseconds", "Time per thread to perform 200 millions jumps in parallel", % Title of the graph, label of y axis and label of x axis.
	{"100m iteration, 0.1 entropy "}, % Labels for curves
	"northeast", "timing-200.eps", "epsc"); % Layout of the legend, file to write the plot to and format of the output file

quickbar(3,
	thread_timing_200, % Plot global timings for 100 millions jumps only, thread by thread.
	'nb_threads', 'thread_time', -1, % column for x values then for y values and base
	"grouped", 0.5, % Style of the bars ("grouped" or "stacked")
	"MgOpenModernaBold.ttf", 25, 800, 400, % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	"Number of threads", "Time in milliseconds", "Time per thread to perform 200 millions jumps in parallel", % Title of the graph, label of y axis and label of x axis.
	{"200m iteration, 0.1 entropy " "thread 1 " "thread 2 " "thread 3 " "thread 4 " "thread 5 " "thread 6 " "thread 7 " "thread 8 "}, % Labels for curves of the previous graph and bars from this graph
	"northeast", "timing-200.eps", "epsc"); % Layout of the legend, file to write the plot to and format of the output file

% Separate graph for task gantt representation
quickgantt(4, ... % fignum
	cell, ... % data, lin_nm, invert,
	{[0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0]}, ... % colors
	0.7, ... % thickness
	{'swne' 'swne' 'swne' 'swne' 'swne' 'swne' 'swne' 'swne' 'swne'}, ... % hatch pattern,
	{'-' '-' '-' '-' '-' '-' '-' '-' '-'}, ... % hatch line style
	{[1 1 1] [1 1 1] [1 1 1] [1 1 1] [1 1 1] [1 1 1] [1 1 1] [1 1 1] [1 1 1]}, ... % hatch color
	2, 1, ... % patterns, patternd
	'MgOpenModernaBold.ttf', 25, ... % fontname, font size
	800, 600, ... % x_size, y_size
	'Time in milliseconds', 'Thread', ['Thread spawn and join accross time'], ... % x_axis, y_axis, grapht, 
	{'Global' 'Thread 1' 'Thread 2' 'Thread 3' 'Thread 4' 'Thread 5' 'Thread 6' 'Thread 7' 'Thread 8'}, ... % graph legend, leglog,
	['gantt.eps'], 'epsc2'); % outf, format
