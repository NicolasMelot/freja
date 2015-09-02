% Copyright 2015 Nicolas Melot
%
% This file is part of Freja.
% 
% Freja is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% Freja is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with Freja. If not, see <http://www.gnu.org/licenses/>.
%




%
% =========================================================================
%
%	Function quickplot
%
%	Plots a curves along x and y axis. Similar to quickerrorbar but without
%	error bars. Output the graphic to a file in eps or png format.
%	
%	Parameters:
%	fignum:	Figure number. A figure of the same number as one or several
%		previously draw ones is draw on the same canvas and produces
%		an output that integrate these previous figures (scalar).
%	table:	Table containing data to be plot (table).
%	colx:	Index in input matrices (table) where the x axis values are 
%		recorded (string).
%	coly:	Indexes in input matrices (table) where the y axis values are 
%		recorded (cell of strings).
%	filter: Where expression ({"[] {[] []}" "[] $[]}"}) to be applied on table
%		for the corresponding column in coly parameter (cell of strings).
%	xval:   Labels to replace each x values (must be of same size as the column
%		pointed by colx *after* the filter is applied). If the cell is
%		empty, the colx column is directly used. (cell of strings).
%	group:	If all values along the x axis are not continuous, draw the plot
%		as if they were (boolean).
%	error:	Base value from which the bar of the histogram start. This
%		shifts up or down the y value to be plotted. When y values are
%		high or zeros, a base of -1 makes possible to see bars
%		representing a zero (scalar).
%	colors:	Colors of the curves to plot. Each color is represented by either
%		a string ('red', 'blue') or an RGB vector (cell of string and/or
%		vectors).
%		Example: {[1 0 0] [1 0 1] [0 0 1] [0 0 0] [0 0.5 0.5] [0 0.5 0]
%			  [0 0 0.5] [0.5 0 0.5]}.
%	marks:	Marks to draw at each point of curves in the graph (examples: 
%		'o' '^' '.' 'x' '>' '<' 'v' '*') (cell of strings).
%	markss:	Size of the marks (scalar).
%	curvew:	Thickness of the curves on the graph (scalar)
%	fontn:	Name of the font to use when writing legend, title and labelling
%		axis. (string)
%	fonts:	Font size of legend, title and axes label (scalar)
%	x_size:	Length of the canvas in pixels, along the x axis (scalar).
%	y_size:	Height of the canvas in pixels, along the y axis (scalar).
%	scale:  Scale the plot to the left make room to an outer legend (scalar).
%		This is a workaround to octave bug #34888.
%	x_axis:	Label for x axis (string).
%	y_axis:	Label for y axis (string).
%	grapht:	Title of the graph (string).
%	xangle: Angle of labels along the x axis.
%	graphl: Label of all curves or bars in the graph (cell of string).
%	legloc: Legend location, for example :'northeast'; see help legend (string).
%	box:	Surround the legend with a frame (boolean).	
%	outf:	Filename to output the graph (string).
%	format:	Descriptor of the output format. Example: 'epsc2'; see help print
%		(string).

function quickplot(fignum, table, colx, coly, filter, xval, group, colors, marks, curvew, markss, fontn, fonts, x_size, y_size, scale, x_axis, y_axis, grapht, xangle, graphl, legloc, box, outf, format)
check(table);

size_data = size(data(table, {''}, 0));
if prod(size_data) == 0
	warning(['No data to plot for graph ' int2str(fignum) ' ''' outf '''; skipping.']);
	return
end
table = orderby(table, {colx});

data_x = cellfindstr(coln(table), colx);
if data_x < 1
	error(['Could not find column ''' colx ''' in table.']);
end

% Disable window popups when generating a new graph
set (0, 'defaultfigurevisible', 'off');

figure(fignum);

hold on;

%% Filter out all labels and references not used for this table
all_x = data(table, {colx}, 0);
all_x = unique(sort(all_x));
size_allx = size(all_x);
size_allx = size_allx(1);
index_x = cellfindstr(coln(table), colx);

allx_labels = {};
allx_alias = {};
allx_ref = {};
allx_values = [];

all_alias = alias(table, {colx}){:};
all_ref = ref(table, {colx}){:};
size_alias = prod(size(all_alias));

allx_values = data(table, {colx}, 0);
maxx = max(all_x);

%% Build the correct alias and ref vector
%% Compute a 'grouped' x vector in case it's needed
for i = 1:size_allx
	allx_labels = {allx_labels{:} int2str(all_x(i))};
	allx_values(allx_values == all_x(i)) = maxx + i;

	if size_alias > 0
		allx_alias = {allx_alias{:} all_alias{all_x(i) + 1}};
		allx_ref = {allx_ref{:} all_ref{all_x(i) + 1}};
	end
end
allx_values -= maxx;

%% If the group option is chose, switch original x vector with continuous values
if group
	table = apply(table, {colx}, {@setC}, {''}, allx_values);
end

%% Fill aliases and references for x with the ones actually used
table{3}{index_x} = allx_alias;
table{4}{index_x} = allx_ref;

all_x = [];
maxi = size(coly);
maxi = maxi(2);
for i = 1:maxi
	data_y = cellfindstr(coln(table), coly{i});
	if data_y < 1
		error(['Could not find column ''' coly{i} ''' in table.']);
	end

	% Data filtering
	filtering = strtrim(filter{i});
	if strcmp(filtering, '') == 0
		filtering=['where(table, ''' filtering ''')'];
	else
		filtering='table';
	end
	src = eval(filtering);
	all_x = [all_x data(src, {colx}, 0)];
	plotting(i) = plot(data(src, {colx}, 0), data(src, {coly{i}}, 0));

	set(plotting(i), 'marker', marks{1, i});
	set(plotting(i), 'markersize', markss);
	set(plotting(i), 'linewidth', curvew);
	set(plotting(i), 'color', colors{1, i});
end

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

set(x_label, 'fontname', fontn);
set(x_label, 'fontsize', fonts);
set(y_label, 'fontname', fontn);
set(y_label, 'fontsize', fonts);
set(g_title, 'fontname', fontn);
set(g_title, 'fontsize', fonts);

set (findobj (gcf, '-property', 'fontname'), 'fontname', fontn);
set (findobj (gcf, '-property', 'fontsize'), 'fontsize', fonts);

data_x_size = data(src, {colx}, 0);
data_x_size = size(data_x_size);
data_x_size = data_x_size(1);
xval_size = prod(size(xval));
if xval_size > 0
	if xval_size < data_x_size
		error(['[quickplot][error] Have ' int2str(data_x_size) ' x values and ' int2str(xval_size) ' labels.']);
		return
	end
	set(gca, 'XTick', data(src, {colx}, 0), 'XTickLabel', xval);
else
	xval_size = prod(size(alias(table, {colx}){:}));
	if xval_size > 0
		if xval_size < maxi
			error(['[quickbar][error] Have ' int2str(maxi) ' x values and ' int2str(xval_size) ' data-embedded labels.']);
			return;
		end
		set(gca, 'XTick', data(src, {colx}, 0), 'XTickLabel', allx_alias);
	else
		if group
			set(gca, 'XTick', data(src, {colx}, 0), 'XTickLabel', allx_labels);
		end
	end
end

%% Squeeze the plot to the left by factor <scale>
set (gca, "position", get (0, "defaultaxesposition") + [0, 0, -1, 0] * scale)

print(outf, ['-d' format], ['-F:' num2str(fonts)], ['-S' num2str(x_size) ',' num2str(y_size)]);

hold off;
set (0, 'defaultfigurevisible', 'on');
	
end

function out = setC(table, coln, aux)
	out = aux;
end
