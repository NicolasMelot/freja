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
%	Function transtable
%
%	Prepares a table from its x column and collection of y indexes for
%	multiple bars to be shown in a bar histogram plot by quickplot.
%	quickplot takes several lines of a single instance of a x value to plot
%	one bar per line in each x instance. When all these lines are not
%	available
%	
%	Parameters:
%	table:	Table containing data to convert (table).
%	colx:	Column containing x values (string).
%	coly:	Group of columns contaning all y values (cell of strings).
%	y_name:	New name to give to the aggregated data column
%
%	Example:
%	a = {
%	      [1,1] =
%		1 1 3 4
%		2 2 7 8
%		3 1 5 6
%		4 3 3 9
%		5 3 5 5
%		6 2 7 7
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%	}
%	b = transpose(a, 'col1', {'col2' 'col4'}, 'y')
%	b = {
%	      [1,1] =
%		1 1
%		1 4
%		2 2
%		2 8
%		3 1
%		3 6
%		4 3
%		4 9
%		5 3
%		5 5
%		6 2
%		6 7
%
%	      [1,2] =
%		col1
%		y
%	}


function bars = transtable(table, colx, coly, y_name)
	table = select(table, coly, 0);
	matrix = data(table, coly, 0);
	size_matrix = size(matrix);
	filter = [];

	for i = 1:log2(size_matrix(1)) + 1
		filter = [filter 2 ^ i + 1];
	end
	table = where(table, {colx}, {filter});

	x = data(table, {colx}, 0);
	x_size = size(x);
	x_size = x_size(1);

	y_size = size(data(table, {''}, 0));
	y_size = y_size(2);

	# Keep only lines whose x are 1 then 0 in order to make sure we have an empty table
	cols = coln(select(table, {colx}, 0));
	cols = {cols{1} y_name};
	matrix = select(table, {colx}, 0);
	matrix = data(matrix, {colx}, 0);
	matrix = [matrix matrix];
	bars = {matrix, cols};

	bars = where(bars, {colx}, {[1]});
	bars = where(bars, {colx}, {[0]});

	for i = 1:x_size
		y = data(where(table, {colx}, {[x(i)]}), except(coln(table), {colx}), 0)';
		head = ones(y_size - 1, 1) .* x(i);
		bars = insert(bars, [head y]);
	end
end
