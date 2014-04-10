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
%	Function where
%
%	Filters the input matrix to keep only the rows fulfilling some arbitrary
%	logical expression.
%	
%	
%	Parameters:
%	table:	The matrix to be filtered (table)
%	cond:	Condition lines in data must meet to be selected as output (string).
%		It must be written in octave/matlab logic operations format
%		(operators, parenthesis). Column names strings (including special
%		characters ._{}^ and space ' ') are replaced by their corresponding
%		index in the table to perform the actual logic check. Similarly,
%		value aliases defined for columns denoting a non-numeric value,
%		possibly through an explicit alias declaration, can be resolved
%		from their column and alias name column::alias (including
%		special characters as defined above).
%	out:	The input matrix without any row which at least one inspected
%		column does not fulfil its requirements (matrix).
%
%	Example:
%	a = {
%	      [1,1] =
%		1 1 3 5
%		1 2 7 8
%		1 1 5 6
%		2 3 3 9
%		2 3 5 4
%		1 2 7 7
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%
%             [1,3] = {{}(0x0) {'alias zero' 'alias one' 'alias two'} {}(0x0) {}(0x0)}
%             [1,4] = {{}(0x0) {'zero' 'one' 'two'} {}(0x0) {}(0x0)}
%	}	
%	b = where(a, '(col2 == col2::one | col2 == col2::two) & col4 <= 8 & col4 >= 5')
%	b = {
%	      [1,1] =
%		1 1 3 5
%		1 2 7 8
%		1 2 7 7
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%
%             [1,3] = {{}(0x0) {'alias zero' 'alias one' 'alias two'} {}(0x0) {}(0x0)}
%             [1,4] = {{}(0x0) {'zero' 'one' 'two'} {}(0x0) {}(0x0)}
%	}

function out = where(table, cond)
	check(table);
	%% Happens in three parts:
	%% * Resolve aliases (format foo::bar) into their constant equivalent and replace them in the condition string
	%% * Resolve variables (non-numeric strings) into its column index and replace them in the condition string
	%% * Filter all matrix lines and keep lines if the recomposed condition is satisfied with this line

	%% Part 1: find and replace all aliases with their value
	%% Find all occurrence of the form (simplified) bla bla bla::hello or bla bla bla::45 
	aliases = regexp(cond, '([\w_{}^.]|[\w_{}^.][\w\d_{,}^.]|[\w_{}^.][ \w\d_{,}^.]+[\w\d_{,}^.])::([\w\d_{}^.]|[\w\d_{}^.][\w\d_{,}^.]|[\w\d_{}^.][ \w\d_{,}^.]+[\w\d_{,}^.])\s*([()&|<>=!+-/*]|$)', 'match');

	%% Resolve the value for each alias
	alias_size = size(aliases);
	alias_size = alias_size(2);
	for i = 1:alias_size
		%% Remove any potential trailing arithmetic sign and remove surrounding spaces
		match = aliases{i};
		match = regexp(match, '([^+*/><!=()|&-]+)[+()*/>|<!&=-]?', 'tokens'){:}{1};
		match = strtrim(match);

		%% Extract column and symbol names
		components = regexp(match, '([^:]+)::(.+)', 'tokens'){1};
		column = components{1};
		symbol = components{2};

		%% Extract the symbol value and check if it could be found
		value = cellfindstr(ref(table, {column}){1}, symbol);
		all_values = data(groupby(table, {column}, {}, {}), {column}, 0);
		if value == 0
			%% The symbol couldn't be resolved. We consider it refers to a values that doesn't exist
			%% We implement it by resolving to the maximum value + 1
			cond = regexprep(cond, [match '(\s*([+()*/>|<!&=-]|$))'], [int2str(max(all_values) + 1) '$1']);
		else
			value = all_values(value);
		
			match = strrep(match, '{', '\{');
			match = strrep(match, '}', '\}');
			match = strrep(match, '^', '\^');
			cond = regexprep(cond, [match '(\s*([+()*/>|<!&=-]|$))'], [int2str(value) '$1']);
		end
	end

	%% Part 2: Resolve line index for each variable
	variables = regexp(cond, '([a-zA-Z_{}]|[a-zA-Z_{}][0-9,a-zA-Z_{}.^]|[a-zA-Z_{}][0-9, a-zA-Z_{}.^]+[0-9,a-zA-Z_{}.^])\s*([()&|<>=!+-/*]|$)', 'match');

	%% Resolve the value for each variable
	variable_size = size(variables);
	variable_size = variable_size(2);
	for i = 1:variable_size
		%% Remove any potential trailing arithmetic sign and remove surrounding spaces
		match = variables{i};
		match = regexp(match, '([^+*/><!=()|&-]+)[+()*/>|<!&=-]?', 'tokens'){:}{1};
		match = strtrim(match);

		%% Extract the symbol value and check if it could be found
		index = cellfindstr(coln(table), match);
		if index == 0
			error(['Cannot resolve column ''' match '''.']);
		end

		match = strrep(match, '{', '\{');
		match = strrep(match, '}', '\}');
		cond = regexprep(cond, [match '(\s*([+()*/>|<!&=-]|$))'], ['table{1}(:, ' int2str(index) ')$1']);
	end

	%% Produce a truth table from the condition synthetized in step 2
	truth = eval(cond);

	%% Use the truth table to address the matrix
	out{1} = table{1}(find(truth), :);

	%% Take out all aliases and references not used anymore
	%% safe column name to store a column telling if a line is selected or not
	where_truth = '__where_truth__';

	%% Build the same table with the truth column
	test = table;
	test{1} = [table{1} truth];
	test{2} = {test{2}{:} where_truth};
	test{3} = {test{3}{:} {}};
	test{4} = {test{4}{:} {}};

	%% Take all columns, old aliases and references and initialize the new ones	
	all_col = coln(table);
	size_cols = size(all_col);
	size_cols = size_cols(2);
	new_alias = {};
	new_ref = {};
	old_alias = alias(table, {''});
	old_ref = ref(table, {''});

	%% Iterate through columns in input table
	for i = 1:size_cols
		%% Initialize a new alias and ref cell for this column
		new_alias = {new_alias{:} {}};
		new_ref = {new_ref{:} {}};

		%% No need to do anything if there is no alias (and consequently no reference) for this column
		if prod(size(old_alias{i})) > 0
			col = all_col{i};
			%% Keep only this column and the truth table; group by on the column name, reduce the truth by sum.
			%% If any occurrence of this culoumn value matches a line that is kept, then the sum is strictly higher 
			%% than 0. Otherwise it is 0.
			tmp = data(groupby(test, {col}, {where_truth}, {@sum}), {col, where_truth}, 0);
		
			%% Compute the number of different values in this column
			size_val = size(tmp);
			size_val = size_val(1);
			for j = 1:size_val
				%% If that value must be kept
				if tmp(j, 2) != 0
					%% Add its reference and alias to the new alias set
					new_alias{i} = {new_alias{i}{:} old_alias{i}{j}};
					new_ref{i} = {new_ref{i}{:} old_ref{i}{j}};
				end
			end
		end
	end

	%% Return column names and value aliases as they came
	out{2} = table{2};
	out{3} = new_alias;
	out{4} = new_ref;
end

