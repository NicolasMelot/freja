%    Copyright 2013 Nicolas Melot
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
%	Function quickgantt
%
%	Plots one or several discontinuous lines along x axis, and label each line
%	as a task in a gantt diagram. No task dependency can be shown.
%	Output the graphic to a file in eps or png format.
%	
%	Parameters:
%	fignum:	Figure number. A figure of the same number as one or several
%		previously draw ones is draw on the same canvas and produces
%		an output that integrate these previous figures (scalar).
%	table:	Table containing the date to be plot in a gantt diagram
%	actor:	Column containing values for all actors in the Gantt chart (string).
%	start:	Column where line start values are stored. If there are several
%		lines for the same actor value, then as many lines are drawn for
%		the same actor (string). 
%	stop:	Column where line stop values are stored. The observation from the
%		start parameter (above) is also valid (string).
%	colors:	Colors of the lines to draw. Each color is represented by either
%		a string ('red', 'blue') or an RGB vector (cell of string and/or
%		vectors).
%	thickn:	Describe how large to draw segments. A value over 1 makes lines to
%		overlap each other. A value lower than 0 is undefined behavior
%		(scalar)
%	ptrn:	Hatch pattern to draw (if any). Diagonals ('nwse'), other diagonals
%		('swne'), horizontal ('hrzt'), vertical ('vert'), crosses ('cross')
%		of squares ('sqrt') (cell of strings)
%	ptrnst:	Pattern line style ('-' '--' ':' '-.' 'none'). Octave support for
%		other styles than '-' is apparently broken (cell of strings).
%	ptrnc:	Color for hatches, similar to colors.
%	ptrns:	Thickness of pattern lines (scalar)
%	ptrnd:	Distance between two pattern lines (scalar)
%	fontn:	Name of the font to use when writing legend, title and labelling
%		axis. (string)
%	fonts:	Font size of legend, title and axes label (scalar)
%	x_size:	Length of the canvas in pixels, along the x axis (scalar).
%	y_size:	Height of the canvas in pixels, along the y axis (scalar).
%	y_axis:	Label for y axis (string).
%	grapht:	Title of the graph (string).
%	outf:	Filename to output the graph (string).
%	format:	Descriptor of the output format. Example: 'epsc2'; see help print
%		(string).

function quickgantt(fignum, table, actor, start, stop, colors, thickn, ptrn, ptrnst, ptrnc, ptrns, ptrnd, fontn, fonts, x_size, y_size, x_axis, y_axis, grapht, outf, format)
ptrnd = ptrnd * 5;
figure(fignum);
hold on;

xmin = 0;
xmax = 0;
cell={};
actor_val = ref(table, {actor}){:};
actor_val_size = size(actor_val);
actor_val_size = actor_val_size(2);

for i = 1:actor_val_size
	cell{i} = data(where(table, [ actor ' == ' actor '::' actor_val{i} ]), {start stop}, 0);
end
graphl = alias(table, {actor}){:};

% Disable window popups when generating a new graph
set (0, 'defaultfigurevisible', 'off');

num_diagram = size(cell);
num_diagram = num_diagram(2);
ylim([0 num_diagram + 1]);
for i=1:num_diagram
	xx = cell{i}(1, :);
	size_xx = size(xx)(2) / 2;

	for j=1:size_xx 
		shift = 2 * (j - 1) + 1;

		if j == 1 && i == 1
			xmin = xx(shift);
			xmax = xx(shift + 1);
		end
		line_end = xx(shift + 1);
		xmin = min(xx(shift), xmin);
		xmax = max(xx(shift + 1), xmax);

		handle{i}(j) = patch([xx(shift) xx(shift) xx(shift + 1) xx(shift + 1)]', [i + thickn / 2 i - thickn / 2 i - thickn / 2 i + thickn / 2]', colors{i});
		set(handle{i}(j), 'EdgeColor', ptrnc{i});
		set(handle{i}(j), 'FaceColor', colors{i});
		set(handle{i}(j), 'LineStyle', ptrnst{i});
		set(handle{i}(j), 'LineWidth', ptrns);
	end
	length = xmax - xmin;
end

% Now the hatching frame is defined, we can safely apply hatches without hatch distance headache
for i=1:num_diagram
	hatch(handle{i}, ptrn{i}, ptrnc{i}, ptrnst{i}, ptrnd, ptrns);
end

g_title = title(grapht);
x_label = xlabel(x_axis);
y_label = ylabel(y_axis);
%legend(graphl, 'location', legloc);
%legend('boxon');
grid on;

set(x_label, 'fontname', fontn);
set(x_label, 'fontsize', fonts);
set(y_label, 'fontname', fontn);
set(y_label, 'fontsize', fonts);
set(g_title, 'fontname', fontn);
set(g_title, 'fontsize', fonts);

set (findobj (gcf, '-property', 'fontname'), 'fontname', fontn);
set (findobj (gcf, '-property', 'fontsize'), 'fontsize', fonts);

set(gca, 'Ytick', [0:num_diagram + 1], 'YTickLabel', {'', graphl{1:num_diagram}, ''}, 'Ylim', [0 num_diagram + 1]);
%set(gca, 'Ytick', [0:num_diagram + 1], 'YTickLabel', {'', graphl{1:num_diagram}, ''}, 'Ylim', [0 num_diagram + 1], 'Xlim', [xmin xmax]);

print(outf, ['-d' format], ['-F:' num2str(fonts)], ['-S' num2str(x_size) ',' num2str(y_size)]);

hold off;
set (0, 'defaultfigurevisible', 'on');

end

