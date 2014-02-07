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
%	Function quickerrorbar
%
%	Plots a curves along x and y axis as well as error bars along the y
%	axis for each point plotted. Similar to quickplot but with error bars.
%	Output the graphic to a file in eps or png format.
%	
%	Parameters:
%	fignum:	Figure number. A figure of the same number as one or several
%		previously draw ones is draw on the same canvas and produces
%		an output that integrate these previous figures (scalar).
%	data:	Table containing data to plot (table).
%	colx:	Column in input table from which x values are extracted 
%		(string).
%	coly:	Columns from input table from which y values are plot (cell of
%		strings). 
%	err:	Columns from input table from which error bars are draw (cell of
%		strings).
%	filter: Where expression ({"[] {[] []}" "[] []}"}) to be applied on table
%		for the corresponding column in coly parameter (cell of strings).
%	xval:   Labels to replace each x values (must be of same size as the column
%		pointed by colx *after* the filter is applied). If the cell is
%		empty, the colx column is directly used. (cell of strings).
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
%	x_axis:	Label for x axis (string).
%	y_axis:	Label for y axis (string).
%	grapht:	Title of the graph (string).
%	graphl: Label of all curves or bars in the graph (cell of string).
%	legloc: Legend location, for example :'northeast'; see help legend (string).
%	outf:	Filename to output the graph (string).
%	format:	Descriptor of the output format. Example: 'epsc2'; see help print
%		(string).

function quickerrorbar(fignum, table, colx, coly, err, filter, xval, colors, marks, curvew, markss, fontn, fonts, x_size, y_size, x_axis, y_axis, grapht, graphl, legloc, outf, format)

data_x = cellfindstr(coln(table), colx);
if data_x < 1
	error(['Could not find column ''' colx ''' in table.']);
end

% Duplicate y and err columns with a new unique name, to avoid a uselessly worrying warning messages about already existing columns
cellsize = size(coly);
cellsize = cellsize(2);
for i = 1:cellsize
	existing = coln(table);
	new_coly{i} = request_name(existing, coly{i});
	new_err{i}  = request_name(existing, err{i});
	table = duplicate(table, {coly{i} err{i}}, {new_coly{i} new_err{i}}, 0);
end
coly = new_coly;
err = new_err;

% Disable window popups when generating a new graph
set (0, 'defaultfigurevisible', 'off');

y_marging = 10;
figure(fignum);

hold on;

maxi = size(coly);
maxi = maxi(2);
for i = 1:maxi
	data_y = cellfindstr(coln(table), coly{i});
	if data_y < 1
		error(['Could not find column ''' coly{i} ''' in table.']);
	end
	data_err = cellfindstr(coln(table), err{i});
	if data_err < 1
		error(['Could not find column ''' err{i} ''' in table.']);
	end

	% Data filtering
	filtering = strtrim(filter{i});
	if strcmp(filtering, '') == 0
		filtering=['where(table, ' filtering ')'];
	else
		filtering='table';
	end
	src = eval(filtering);

	plotting(i) = errorbar(data(src, {colx}, 0), data(src, {coly{i}}, 0), data(src, {err{i}}, 0));

	max_value = max(max(data(src, coly, 0) + data(src, err, 0)));
	min_value = min(min(data(src, coly, 0) - data(src, err, 0)));

	set(plotting(i), 'marker', marks{1, i});
	set(plotting(i), 'markersize', markss);
	set(plotting(i), 'linewidth', curvew);
	set(plotting(i), 'color', colors{1, i});
end

ylim([min_value - (max_value - min_value) / y_marging, max_value + (max_value - min_value) / y_marging]);

% Here come the general graph settings
g_title = title(grapht);
x_label = xlabel(x_axis);
y_label = ylabel(y_axis);
legend(graphl, 'location', legloc);
legend('boxon');

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
		error(['[quickerrorbar][error] Have ' int2str(data_x_size) ' x values and ' int2str(xval_size) ' labels.']);
		return
	end
	set(gca, 'XTick', data(src, {colx}, 0), 'XTickLabel', xval);
end

print(outf, ['-d' format], ['-F:' num2str(fonts)], ['-S' num2str(x_size) ',' num2str(y_size)]);

hold off;
set (0, 'defaultfigurevisible', 'on');
	
end
