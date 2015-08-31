


%
% =========================================================================
%
%	Function alias
%
%	Extract aliases for values contained in columns given as input
%	
%	
%	Parameters:
%	table:	The table from where to read aliases (table).
%	cols:	Column from where to extract alises. An empty string denotes
%		all columns. A column selected twice or more duplicates the
%		aliases collection (cell of strings).
%		to be returned (list of strings).
%	out:	All aliases ordered as cols parameter (cell of cells of strings).
%
%	Example:
%	a = {
%	      [1,1] =
%		1 1 3 4
%		1 2 7 8
%		1 1 5 6
%		2 3 3 9
%		2 3 5 5
%		1 2 7 7
%
%	      [1,2] =
%		english
%		spanish
%		french
%		swedish
%
%             [1,3] = {{'label zero' 'label one'} {'label zero' 'label en' 'label dos' 'label tre'} {'label un' 'label deux' 'label trois' 'label quatre' 'label cinq' 'label six' 'label sept'} {'label en' 'label tva' 'label tre' 'label fyra' 'label fem' 'label sex' 'label sju' 'label atta' 'label nio'}}
%             [1,4] = {{'zero' 'one'} {'zero' 'en' 'dos' 'tre'} {'un' 'deux' 'trois' 'quatre' 'cinq' 'six' 'sept'} {'en' 'tva' 'tre' 'fyra' 'fem' 'sex' 'sju' 'atta' 'nio'}}
%	}
%	b = alias(a, {'spanish' 'swedish'})
%	b = {
%             {'label zero' 'label en' 'label dos' 'label tre'} {'label en' 'label tva' 'label tre' 'label fyra' 'label fem' 'label sex' 'label sju' 'label atta' 'label nio'}
%	}

function out = alias(table, cols)
	check(table);

	out = {};
	csize = size(cols);
	csize = csize(2);

	for i = 1:csize
		if strcmp(cols{i}, '')
			out = {out{:} table{3}{:}};
		else
			index = cellfindstr(coln(table), cols{i});
			if index > 0
				out = { out{:} table{3}{index} };
			end
		end
	end
end
