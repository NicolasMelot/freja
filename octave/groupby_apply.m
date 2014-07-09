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
%	Function groupby_apply
%
%	Applies a function to subgroups of a matrix, as defined by as
%	list of columns to form groups from.
%	
%	
%	Parameters:
%	table:	The table containing data to apply the function to (table).
%	colg:	Cell of columns names to form groups from (cell of strings).
%	col:	Cell of column names where function outputs are written.
%		Note processing order is undefined (cell of strings).
%	func:	Functions to apply to the tables' rows (pointer to function).
%		Usually a user-defined function denoted by @<function_name>.
%		The function must take the followin signature:
%		function y = <function_name>(table, coln, aux), where:
%		* Table is the same table as apply function table argument
%		  (table).
%		* coln is the column name where result is written (string).
%		* aux is an aribraty value of an arbitrary type copied as is
%		  when apply calls the function (user-defined type)
%		* output is the result vector, exactly as long as table has
%		  lines (vector).
%	aux	Auxiliary data the user may need to pass to functions
%		(user-defined type).
%	out:	The table after computation.

function out = groupby_apply(table, colg, col, func, aux)
	check(table);

	%% Reorder columns so groups come first
	not_colg = except(coln(table), colg);
	table = select(table, {colg{:} not_colg{:}}, 0);

	%% Group the table by given columns colg
	%% And get all the unique lines defined by the group
	filters = groupby(table, colg, {}, {});
	comp = data(select(filters, not_colg, 0), {''}, 0);
	filters = data(filters, colg, 0);

	size_f = size(filters);
	size_f = size_f(1);

	size_g = size(colg);
	size_g = size_g(2);

	%% For all filters, apply the function
	for i = 1:size_f
		matrix = data(table, {''}, 0);
		discard = matrix(find(1 - all(bsxfun(@eq, [filters(i,:) comp(i, :)], matrix)(:,1:size_g),2)),:);
		matrix = matrix(find(all(bsxfun(@eq, [filters(i,:) comp(i, :)], matrix)(:,1:size_g),2)),:);

		tmp = table;
		tmp{1} = matrix;
		tmp = apply(tmp, {col}, {func}, {''}, aux);
		table{1} = [tmp{1}; discard];
	end

	out = table;
end

