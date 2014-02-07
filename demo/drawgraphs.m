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
%	Plot the data collected and processed at the previous step, using
%	all plotting primitives. This parts takes parameters from the settings file
%

%% First process the data
process

% Third part: use plotting function to generate graphs, format and store them in graphic files.
% /!\ Matlab does not support line breaks in the middle of function calls. If you use Matlab, remove the comments and write the function call to quickplot, quickerrorbar and and quickbar in one line only.
num = 1;
quickplot(num,
	global_timing_04, % Table to take data from
	'nb threads', % Column for x values
	{'global time', 'global time'}, % Columns for y values
	{'{''ct''}, {[100000000]}', '{''ct''}, {[200000000]}'}, % Filters for columns mentioned earlier.
	{}, % Label to replace x values. Use raw values
	colors{num}, % Colors to be applied to the curves, written in RGB vector format
	markers{num}, % Enough markers for 6 curves. Browse the web to find more.
	thickness{num}, marker_size{num}, font{num}, font_size{num}, width{num}, height{num}, % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	'Number of threads', 'Time in milliseconds', 'Global time to perform 100 and 200 millions jumps in parallel', % Title of the graph, label of y axis and label of x axis.
	{'100m iteration, 0.4 entropy ' '200m iteration, 0.4 entropy '}, % Labels for curves
	legend_location{num}, legend_box{num}, [ output_prefix{num} int2str(num) '_' 'timing-error' '.' output_extension{num}], output_format{num}); % Layout of the legend, file to write the plot to and format of the output file

% The two following graphs are combined together
num = 2;
quickerrorbar(num,
	global_timing_04, % Plot global timings.
	'nb threads', % Column for x
	{'global time'}, % Columns for y (one curve per column)
	{'global stddev'}, % Columns for standard deviation
	{'{''ct''}, {[100000000]}'}, % Filters for each curve to be plotted (100 million jumps only)
	{}, % Label to replace x values. Use raw values
	colors{num}, % Colors to be applied to the curves, written in RGB vector format
	markers{num}, % Enough markers for 6 curves. Browse the web to find more.
	marker_size{num}, thickness{num}, font{num}, font_size{num}, width{num}, height{num}, % Markers size, curves' thickness, Font name and font size, canvas' width and height
	'Number of threads', 'Time in milliseconds', 'Time per thread to perform 100 millions jumps in parallel', % Title of the graph, label of y axis and label of x axis.
	{'100m iteration, 0.1 entropy '}, % Labels for curves
	legend_location{num}, legend_box{num}, [ output_prefix{num} int2str(num) '_' 'timing-100' '.' output_extension{num}], output_format{num}); % Layout of the legend, file to write the plot to and format of the output file

quickbar(num,
	prebar(where(thread_timing_04, {'ct'}, {[100000000]}), 'nb threads', 'thread time', 0), % Plot global timings for 100 millions jumps only, thread by thread.
	'nb threads', % x values
	{'thread time', 'thread time 2', 'thread time 3', 'thread time 4', 'thread time 5', 'thread time 6', 'thread time 7', 'thread time 8'}, % Values for y, one column per bar
	'', % Data filter to apply before plotting (100 million jumps only)
	{}, % Label to replace x values. Use raw values
	'grouped', 0.5, % Style of the bars ('grouped' or 'stacked')
	'MgOpenModernaBold.ttf', 8, 800, 400, % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	'Number of threads', 'Time in milliseconds', 'Time per thread to perform 100 millions jumps in parallel', % Title of the graph, label of y axis and label of x axis.
	{'100m iteration, 0.1 entropy ' except(alias(table, {'thread'}){:}, {'SEQ'}){:}}, % Labels for curves of the previous graph and bars from this graph
	legend_location{num}, legend_box{num}, [ output_prefix{num} int2str(num) '_' 'timing-100' '.' output_extension{num}], output_format{num}); % Layout of the legend, file to write the plot to and format of the output file

% The two following graphs are combined together
num = 3;
quickerrorbar(3,
	global_timing_04, % Plot global timings.
	'nb threads', % Column for x
	{'global time'}, % Columns for y (one curve per column)
	{'global stddev'}, % Columns for standard deviation
	{'{''ct''}, {[200000000]}'}, % Filters for each curve to be plotted (100 million jumps only)
	{}, % Label to replace x values. Use raw values
	colors{num}, % Colors to be applied to the curves, written in RGB vector format
	markers{num}, % Enough markers for 6 curves. Browse the web to find more.
	marker_size{num}, thickness{num}, font{num}, font_size{num}, width{num}, height{num}, % Markers size, curves' thickness, Font name and font size, canvas' width and height
	'Number of threads', 'Time in milliseconds', 'Time per thread to perform 200 millions jumps in parallel', % Title of the graph, label of y axis and label of x axis.
	{'100m iteration, 0.1 entropy '}, % Labels for curves
	legend_location{num}, legend_box{num}, [ output_prefix{num} int2str(num) '_' 'timing-200' '.' output_extension{num}], output_format{num}); % Layout of the legend, file to write the plot to and format of the output file

quickbar(num,
	prebar(where(thread_timing_04, {'ct'}, {[200000000]}), 'nb threads', 'thread time', 0), % Plot global timings for 100 millions jumps only, thread by thread.
	'nb threads', % x values
	{'thread time', 'thread time 2', 'thread time 3', 'thread time 4', 'thread time 5', 'thread time 6', 'thread time 7', 'thread time 8'}, % Values for y, one column per bar
	'', % Data filter to apply before plotting (100 million jumps only)
	{}, % Label to replace x values. Use raw values
	'grouped', 0.5, % Style of the bars ('grouped' or 'stacked')
	'MgOpenModernaBold.ttf', 8, 800, 400, % Curves' thickness, markers sizes, Font name and font size, canvas' width and height
	'Number of threads', 'Time in milliseconds', 'Time per thread to perform 200 millions jumps in parallel', % Title of the graph, label of y axis and label of x axis.
	{'200m iteration, 0.1 entropy ' except(alias(table, {'thread'}){:}, {'SEQ'}){:}}, % Labels for curves of the previous graph and bars from this graph
	legend_location{num}, legend_box{num}, [ output_prefix{num} int2str(num) '_' 'timing-200' '.' output_extension{num}], output_format{num}); % Layout of the legend, file to write the plot to and format of the output file

% Separate graph for task gantt representation
num=4;
quickgantt(num, ... % fignum
	cell, ... % data,
	colors{num}, ... % colors
	hatch_thickness{num}, ... % thickness
	hatch_pattern{num}, ... % hatch pattern,
	hatches{num}, ... % hatch line style
	hatch_colors{num}, % Colors to be applied to the curves, written in RGB vector format
	pattern_thickness{num}, pattern_space{num}, ... % patterns, patternd
	font{num}, font_size{num}, ... % fontname, font size
	width{num}, height{num}, ... % respectively: canvas width and height
	'Time in milliseconds', 'Thread', ['Thread spawn and join accross time'], ... % x axis, y axis, graph title, 
	{'Global' except(alias(table, {'thread'}){:}, {'SEQ'}){:} }, ... % labels for each bar
	[ output_prefix{num} int2str(num) '_' 'gantt' '.' output_extension{num} ], output_format{num}); % File to write the plot to and format of the output file
