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
% =========================================================================
%
%	Function quickbar
%
%	Plots an histogram from the data given as input parameters, format
%	and decorate it (legend, title, axis, etc) and output it to a graphic
%	file eps or png. The histogram can feature several bars per step along
%	the x axis, defined by all columns defined in coly parameter.
%	
%	
%	Parameters:
%	fignum:	Figure number. A figure of the same number as one or several
%		previously draw ones is draw on the same canvas and produces
%		an output that integrate these previous figures (scalar).
%	table:	Matrix containing x and y values to be plotted (matrix).
%	colx:	Column name in input table where the x axis values are 
%		recorded (string).
%	coly:	All columns where y data is fetch from, one per bar at every x
%		value (cell of strings).
%	filter: 'where' expression ('[] {[] []}') to be applied on table
%		for all columns in coly parameter. '' is no filter (strings).
%	xval:   Labels to replace each x values (must be of same size as the column
%		pointed by colx *after* the filter is applied). If the cell is
%		empty, the colx column is directly used. (cell of strings).
%	group:	If all values along the x axis are not continuous, draw the plot
%		as if they were (boolean).
%	style:	Style of the bar groups at each x step. For instance 'grouped'
%		or 'stacked'; see help bar (string).
%	thickn:	Thickness of the bars on the graph (scalar)
%	fontn:	Name of the font to use when writing legend, title and labelling
%		axis. (string)
%	fonts:	Font size of legend, title and axes label (scalar)
%	x_size:	Length of the canvas in pixels, along the x axis (scalar).
%	y_size:	Height of the canvas in pixels, along the y axis (scalar).
%	x_axis:	Label for x axis (string).
%	y_axis:	Label for y axis (string).
%	grapht:	Title of the graph (string).
%	graphl: Label of all curves or bars in the graph (cell of string).
%	legloc: Legend location, for example :'northeast'; see help legend (string).
%	box:	Surround the legend with a frame (boolean).	
%	outf:	Filename to output the graph (string).
%	format:	Descriptor of the output format. Example: 'epsc2'; see help print
%		(string).

function quickbar(fignum, table, colx, coly, filter, xval, group, style, thickn, fontn, fonts, x_size, y_size, x_axis, y_axis, grapht, graphl, legloc, box, outf, format)
%% Define a label for mock x values in the case of providing a unique x values that the backend bar() function cannot handle
empty_label = '';
check(table);

size_data = size(data(table, {''}, 0));
if prod(size_data) == 0
	warning(['No data to plot for graph ' int2str(fignum) ' ''' outf '''; skipping.']);
	return
end

table = orderby(table, {colx});

data_x = cellfindstr(coln(table), colx);
if data_x < 1
	error(['Cound not find column ''' colx ''' in table.']);
end

y_marging = 10;
figure(fignum);

% Data filtering
filtering = strtrim(filter);
if strcmp(filtering, '') == 0
	filtering=['where(table, ''' filtering ''');'];
else
	filtering='table;';
end
src = eval(filtering);

src = data(src, coly, 0);
src = src';

coly_size = size(coly);
coly_size = coly_size(2);

colx_size = size(data(table, {colx}, 0));
colx_size = colx_size(1);

if group
	all_x = data(table, {colx}, 0);
	size_allx = size(all_x);
	size_allx = size_allx(1);

	allx_labels = {};
	allx_alias = {};
	allx_ref = {};
	allx_values = [];

	all_alias = alias(table, {colx}){:};
	all_ref = ref(table, {colx}){:};
	size_alias=prod(size(all_alias));

	for i = 1:size_allx
		allx_labels = {allx_labels{:} int2str(all_x(i))};
		allx_values(i) = i;

		if size_alias > 0
			allx_alias = {allx_alias{:} all_alias{all_x(i) + 1}};
			allx_ref = {allx_ref{:} all_ref{all_x(i) + 1}};
		end
	end

	all_x = allx_values;
end

matrix = [];
for i = 1:colx_size
	x = all_x(i);
	coly_x = src(:, i);
	matrix_x = ones(coly_size, 1) .* x;
	matrix_x = [matrix_x coly_x];
	matrix = [matrix; matrix_x];
end
table = {matrix, {colx, 'coly'} {allx_alias alias(table, {coly{1}}){:}} {allx_ref ref(table, {coly{1}}){:}} };
coly = 'coly';

x = data(groupby(select(table, {colx}, 0), {colx}, {}, {}), {colx}, 0);
current_x_data = where(table, [ colx ' == ' int2str(x(1)) ]);
y = data(current_x_data, {coly}, 0);

maxi = size(x);
maxi = maxi(1);
for i = 2:maxi
	current_x_data = where(table, [ colx ' == ' int2str(x(i)) ]);
	y = [y data(current_x_data, {coly}, 0)];
end

% Disable window popups when generating a new graph
set (0, 'defaultfigurevisible', 'off');

hold on;

%% If there is only one x value, bar() will fail. Create two more x values before and after the unique existing x value
size_x = size(x);
size_x = size_x(1);
if size_x == 1
	x = [x - 1; x; x + 1];
	size_y = size(y);
	y = [zeros(size_y) y zeros(size_y)];

	%% Update the xval labels fo each x values
	
end
handle = bar(x, y', thickn, style);

if style == 'grouped'
max_value = max(max(y));
else
max_value = max(sum(y));
end
min_value = min(min(y));

ylim([min_value - (max_value - min_value) / y_marging, max_value + (max_value - min_value) / y_marging]);

% Here come the general graph settings
g_title = title(grapht);
x_label = xlabel(x_axis);
y_label = ylabel(y_axis);
legend(graphl, 'location', legloc);
if box
	legend('boxon');
else
	legend('boxoff');
end
	
grid off;

set(x_label, 'fontname', fontn);
set(x_label, 'fontsize', fonts);
set(y_label, 'fontname', fontn);
set(y_label, 'fontsize', fonts);
set(g_title, 'fontname', fontn);
set(g_title, 'fontsize', fonts);

set (findobj (gcf, '-property', 'fontname'), 'fontname', fontn);
set (findobj (gcf, '-property', 'fontsize'), 'fontsize', fonts);

%% Manage labels for all x values
xval_size = prod(size(xval));
if xval_size > 0
	%% If there is only one real x value, remove mockup values to create only one label
	if maxi == 1
		x = x(2);
	end
	if xval_size < maxi
		error(['[quickbar][error] Have ' int2str(maxi) ' x values and ' int2str(xval_size) ' labels.']);
		return
	end
	set(gca, 'XTick', x, 'XTickLabel', xval);
else
	xval_size = prod(size(alias(table, {colx}){:}))
	if xval_size > 0
		if xval_size < maxi
			error(['[quickbar][error] Have ' int2str(maxi) ' x values and ' int2str(xval_size) ' data-embedded labels.']);
			return;
		end

		xval = alias(table, {colx}){:}
		%% If there is only one real x value, remove mockup values to create only one label
		if maxi == 1
			x = x(2);
		end
		set(gca, 'XTick', x, 'XTickLabel', xval);
	else
		if group
			%% If there is only one real x value, remove mockup values to create only one label
			if maxi == 1
				x = x(2);
			end
			set(gca, 'XTick', x, 'XTickLabel', allx_labels);
		end
	end
end

print(outf, ['-d' format], ['-F:' num2str(fonts)], ['-S' num2str(x_size) ',' num2str(y_size)]);

hold off;
set (0, 'defaultfigurevisible', 'on')
	
end

