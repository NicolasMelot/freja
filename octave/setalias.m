function out = setalias(table, cols, aliases)
	check(table);

	size_cols = size(cols);
	size_cols = size_cols(2);

	out = table;

	for i = 1:size_cols
		index = cellfindstr(coln(table), cols{i});
		if index > 0
			out{3}{i} = aliases{i};
		else
			error(['Cannot find column ''' cols{i} '''.']);
		end
	end
end
