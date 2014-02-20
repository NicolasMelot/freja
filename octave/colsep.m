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
%	Function colsep
%
%	Prepares a table to be plotted using quickbar, where values for bars
%	are not held in different columns but all in one column and several
%	values are available for each x (such as the thread runtime). Creates
%	additional columns for each value in a given x, move data there and
%	name that column after the name of the input column, append with an
%	underscore _ and a number, is such column name doesn't already exist.
%	In that case, the new name is appended with another underscore and
%	number, until a non-confliting name is found.
%	
%	Parameters:
%	table:	Table containing data to convert (table).
%	colx:	Column containing x values (string).
%	coly:	Column where y values are stored (string).
%	def:	Default value to give if the table lacks values
%
%	Example:
%	a = {
%	      [1,1] =
%		1 1 3 4
%		2 2 7 8
%		2 1 5 6
%		3 3 3 9
%		3 3 5 5
%		3 2 7 7
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%
%             [1,3] = {{'label zero' 'label one' 'label two' 'label three'} {'label zero' 'label un' 'label deux' 'label trois'} {}(0x0) {}(0x0)}
%             [1,4] = {{'zero' 'one' 'two' 'three'} {'zero' 'un' 'deux' trois'} {}(0x0) {}(0x0)}
%	}
%	b = separate(a, 'col1', 'col2', 0)
%	b = {
%	      [1,1] =
%		1 1 0 0 3 4
%		2 2 1 0 7 8
%		2 2 1 0 5 6
%		3 3 3 2 3 9
%		3 3 3 2 5 5
%		3 2 3 2 7 7
%
%	      [1,2] =
%		col1
%		col2
%		col2_2
%		col2_3
%		col3
%		col4
%
%             [1,3] = {{'label zero' 'label one' 'label two' 'label three'} {'label zero' 'label un' 'label deux' 'label trois'} {'label zero' 'label un' 'label deux' 'label trois'} {'label zero' 'label un' 'label deux' 'label trois'} {}(0x0) {}(0x0)}
%             [1,4] = {{'zero' 'one' 'two' 'three'} {'zero' 'un' 'deux' 'trois'} {'zero' 'un' 'deux' trois'} {'zero' 'un' 'deux' trois'} {}(0x0) {}(0x0)}
%	}

function out = colsep(table, colx, coly, def)
	check(table);
	% Additional columns needed in the process
	column_size = 'no_warning_group_size'; % If you modify this value, don't forget to modify also the one used in function reset_line below
	line_id = 'no_warning_line_id';

	% Phase 1: clone lines so each group is of the same size
	% Make a new row for group sizes
	out = select(table, {'' column_size, line_id}, 0);
	% Give each line the size of the group they belong to
	out = groupby(out, {colx}, {coly column_size}, {@alllines, @group_size});
	% How much lines per group (how much columns are to be created? Useful for next phase)
	lines_per_group = data(out, {column_size}, 0);
	lines_per_group = max(lines_per_group);
	% Spread out maximal group size to all lines
	out = apply(out, {column_size}, {@spread_max_size}, 0);
	% Write in extra column how many duplicate we need
	out = groupby(out, {colx}, {coly column_size}, {@alllines, @how_many_duplicate});
	% Give each line a unique identifier
	out = apply(out, {line_id}, {@give_lines_id}, 0);
	% Isolate each line, duplicate lines marked as such and mark duplicate lines as opposed to others
	out = groupby(out, {line_id}, {column_size}, {@do_duplicate});
	% Reset all duplicate lines with def
	out = apply(out, {coly}, {@reset_line}, def);
	% Get rid of all additional temporary columns
	out = select(out, except(coln(out), {column_size, line_id}), 0);

	% Move data so they are organized in columns instead of columns under a unique x value
	% Clone coly column as much as needed
	for i = 2:lines_per_group
		data_y = data(out, {coly}, 0);
		alias_y = alias(out, {coly});
		ref_y = ref(out, {coly});

		data_all = data(out, {''}, 0);
		alias_all = alias(out, {''});
		ref_all = ref(out, {''});

		names = coln(out);
		data_y = circshift(data_y, -i + 1);
		out = { [data_all data_y] { names{:} request_name(names, coly) } { alias_all{:} alias_y{:} } { ref_all{:} ref_y{:} } };
	end

	% Final: get rid of all lines becoming useless
	out = groupby(out, {colx}, {}, {});
end

function out = clone_line(vector)
	len = size(vector);
	len = len(1);
	out = 1:len;
end

function out = spread_max_size(table, coln, aux)
	vect = data(table, {coln}, 0);
	out = ones(size(vect)) .* max(vect);
end

function out = give_lines_id(table, coln, aux)
	vect = data(table, {coln}, 0);
	len = size(vect);
	len = len(1);

	out = 1:len;
end

function out = group_size(vector)
	out = prod(size(vector));
end

function out = how_many_duplicate(vector)
	goal = vector(1, 1);
	current = size(vector);
	current = current(1);

	out = zeros(size(vector));
	out(current, 1) = goal - current;
end

function out = do_duplicate(vector)
	out = 1:vector(1, 1);
	out = out .* 0;
	out = out + 1;
	out = out .* vector(1, 1);
	out = [0; out'];
end

function yval = reset_line(table, coln, aux)
	column_size = 'no_warning_group_size';

	yval = data(table, {coln}, 0);
	duplicate = data(table, {column_size}, 0);
	duplicate = duplicate > 0;
	mask = 1 - duplicate;
	yval = yval .* mask;
	yval = yval + (duplicate .* aux);
end

