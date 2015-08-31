

%
% =========================================================================
%
%	Function apply
%
%	Applies a function to a matrix row by row, and writes its scalar
%	output in the approriate column of this matrix in the same row.
%	
%	
%	Parameters:
%	table:	The table containing data to apply the function to (table).
%	coln:	Cell of column names where function outputs are written.
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
%	cond:	"where()" expressions to limit the application of function
%		"func" to the line where the condition is fulfilled (cell
%		of strings). If any pai of filtering expression match a
%		common subset of the table, then the function ultimately
%		applied to this subset is undefined and others have not
%		effect.
%	aux	Auxiliary data the user may need to pass to functions
%		(user-defined type).
%	out:	The table after computation.

function out = apply(table, col, func, cond, aux)
	check(table);

	%% Apply the transformations to the table
	size_matrix = size(table{1});
	size_y = size_matrix(1);

	col_size = size(col);
	col_size = col_size(2);

	for j = 1:col_size
		% Split the table into one part satisfying the condition
		if strcmp(strtrim(cond{j}), '')
			cond{j} = '1';
		end
		not_cond = ['!(' cond{j} ')'];
		left = where(table, not_cond);

		%% Extract the matrix we modify from the table
		target = where(table, cond{j});
		matrix = data(target, {''}, 0);

		index = cellfindstr(table{2}, col{j});
		if index > 0
			matrix(:, index) = func{j}(target, col{j}, aux);
		else
			error(['Couldn''t find column ''' col{j} '''.']);
		end

		%% Put back the modified matrix and the discarded data
		table{1} = [matrix; data(left, {''}, 0)];
	end

	out = table;

	%out{1} = data(able, '', 0);
	%out{2} = table{2};
	%out{3} = table{3};
	%out{4} = table{4};
end

