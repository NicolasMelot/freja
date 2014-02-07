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
%	Loads and transforms the data collected through experiments, using
%	All data manipulation functions as well as custom functions. This script
%	is very dense regarding the meaning of all statements and parameters. Be
%	very carefull when modifying or writing such a file as errors may be tiny
%	but have drastic consequences and are difficult to track.
%	

%% Load settings
settings

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

function y = cp_start_sec(row, col)
	y = data(row, {'start time sec'}, 0);
end
function y = cp_start_nsec(row, col)
	y = data(row, {'start time nsec'}, 0);
end
function y = cp_stop_sec(row, col)
	y = data(row, {'stop time sec'}, 0);
end
function y = cp_stop_nsec(row, col)
	y = data(row, {'stop time nsec'}, 0);
end
function y = set_thread_zero(row, col)
	y = 0;
end

% First part: filtering, selection and basic transformations
collected = select(table, {'entropy' 'nb threads' 'ct' 'thread' 'start time sec' 'start time nsec' 'stop time sec' 'stop time nsec' 'thread start sec' 'thread start nsec' 'thread stop sec' 'thread stop nsec'}, 0); % Keep every columns except the try number.
collected = where(collected, {'nb threads'}, {[0 1 2 3 4 5 6 7 8]}); % Keeps only measurements involving sequential or 1, 2, 4 and 8 threads.
collected = duplicate(collected, {'stop time nsec' 'thread stop nsec'}, {'global time' 'thread time'}, 1); % Duplicate two columns. The new columns will be used to store the computed time difference between start and stop for both global and per-thread process.
collected = apply(collected, {'global time' 'thread time'}, {@time_difference_global, @time_difference_thread}, 0); % Compute the global start-stop difference
collected = select(collected, {'entropy' 'nb threads' 'ct' 'thread' 'global time' 'thread time'}, 0); % keep every features (entropy, number of threads, number of jumps and thread number) plus the time differences calculated earlier.
collected = duplicate(collected, {'global time' 'thread time'}, {'global stddev' 'thread stddev'}, 2); % Create 2 more columns to calculate timing standard deviations

% Second part: extraction and reshaping to produce smaller matrices
% Global timings
global_timing = groupby(collected, {'entropy' 'nb threads' 'ct'}, {'global time' 'thread time' 'global stddev' 'thread stddev'}, {@mean, @mean, @std, @std}); % Separate into groups defined by entropy, number of threads and number of loops
global_timing_04 = where(global_timing, {'entropy'}, {[0.4]}); % Select rows denoting experiments with an entropy of 0.1 and performing 200 million jumps.

% Timings per thread
thread_timing = groupby(collected, {'entropy' 'nb threads' 'ct' 'thread'}, {'global time' 'thread time' 'global stddev' 'thread stddev'}, {@mean, @mean, @std, @std}); % Separate into groups defined by entropy, number of threads, number of loops and thread number.
thread_timing = extend(thread_timing, {'entropy' 'nb threads' 'ct'}, {'thread'}, 0); % Extend groups that do not involve the maximum amount of threads and copy the thread number to each rows of extended groups. Fills the rest with 0 (non-existent threads work for a null period of time.
thread_timing_04 = where(thread_timing, {'entropy'}, {[0.4]}); % Select rows denoting experiments with an entropy of 0.1 and performing 200 million jumps.

% Gather start and stop time for global and each thread, target to a gantt diagram
table = where(table, {'ct'}, {[100000000]});
max_threads = max(data(select(table, {'nb threads'}, 0), {'nb threads'}, 0)); % Get maximum number of thread in this data
max_ct = max(data(select(table, {'ct'}, 0), {'ct'}, 0)); % Get maximum jump count from this data
table = where(table, {'nb threads' 'ct'}, {[max_threads] [max_ct]}); % Actually select data for max amount of thread and jump count
table = select(table, {'entropy', 'try', 'thread', 'start time sec', 'start time nsec', 'stop time sec', 'stop time nsec', 'thread start sec', 'thread start nsec', 'thread stop sec', 'thread stop nsec'}, 0); % eliminate nb threads and ct columns
% Create new lines for global time, in order to fit data shape to quickgantt function
globals = groupby(table, {'try'}, {'entropy', 'try', 'thread', 'start time sec', 'start time nsec', 'stop time sec', 'stop time nsec', 'thread start sec', 'thread start nsec', 'thread stop sec', 'thread stop nsec'}, {@mean, @mean, @mean, @mean, @mean, @mean, @mean, @mean, @mean, @mean, @mean}); % Isolate data gather per try number and apply a mean to every other columns. We only care about try columns and global time values here. The rest is '@mean'ed' but we won't keep it. 
globals = apply(globals, {'thread' 'thread start sec' 'thread start nsec' 'thread stop sec' 'thread stop nsec'}, {@set_thread_zero, @cp_start_sec, @cp_start_nsec, @cp_stop_sec, @cp_stop_nsec}, 0); % Reset thread number to 0 (to denote global time) and copy columns for global timing to thread columns

table = insert(table, data(globals, {'entropy', 'try', 'thread', 'start time sec', 'start time nsec', 'stop time sec', 'stop time nsec', 'thread start sec', 'thread start nsec', 'thread stop sec', 'thread stop nsec'}, 0)); % Insert this new data to the table. Lines of thread = 0 now denote global time.
% Sort data so the newly inserted lines for thread 0 take position next to the relevant line for thread 1, instead of undefined position after insert operation
matrix = data(table, {'entropy', 'try', 'thread', 'start time sec', 'start time nsec', 'stop time sec', 'stop time nsec', 'thread start sec', 'thread start nsec', 'thread stop sec', 'thread stop nsec'}, 0); % Get data matrix out
matrix = sortrows(matrix, 3); % Sort it along thread number: fits thread 0 line before every thread 1 line
matrix = sortrows(matrix, 2); % Sort it back along try column to get back into original order
table = setd(table, matrix); % Put matrix back into table

% Compute thread (and global) start and stop time
table = duplicate(table, {'none' 'none'}, {'thread start' 'thread stop'}, -1); % Create new columns for start and stop values
table = apply(table, {'thread start' 'thread stop'}, {@thread_start, @thread_stop}, 0); % Apply conversion functions
table = groupby(table, {'thread'}, {'thread start' 'thread stop'}, {@mean, @mean}); % Group by thread number and reduce groups using mean function

% Split every line into an inpendant line and put them in a cell so we can fit format for quickgantt (the reason is lines must be same length in matrices, but gantt needs different lines of different length).
matrix = data(table, {'thread start' 'thread stop'}, 0); % Extracts thread start and thread stop columns from matrix
msize = size(matrix); % Gets matrix' size
msize = msize(1); % Gets Matrix' number of lines
cell = {}; % Initialize a cell
for i = 1:msize
	cell{i} = matrix(i, :); % Add a matrix's line to the cell
end

