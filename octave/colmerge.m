

%
% =========================================================================
%
%	Function colmerge
%
%	Rearranges data spread out in several columns to one unique column
%	in several lines. Values of column colx are replicated to these lines
%	to form groups defined by column x. This operation is suitable to
%	prepare a table to a gantt chart drawing, where several start and stop
%	values for line segments are defined in several columns.
%	
%	Parameters:
%	table:	Table containing data to convert (table).
%	colx:	Column containing x values (string).
%	coly:	Group of columns to merge into one (cell of cells of strings).
%		Note that the function has no effect is all cells have only
%		one column name, beside cutting other columns.
%	y_name:	New name to give to the aggregated data column (cell of strings).
%	out:	The table after rearranging data. Only columns colx and y_name
%		are kept (table).
%
%	Example:
%	a = {
%	      [1,1] =
%		1 1 6 5 2 7 
%		2 2 8 4 1 9
%		3 1 5 2 6 8
%		4 3 8 5 7 9
%		5 3 8 7 1 9
%		6 2 4 3 0 6
%
%	      [1,2] =
%		thread
%		start1
%		start2
%		stop1
%		garbage
%		stop2
%
%	      [1,3] =
%		{'Global' 'T1' 'T2' 'T3' 'T4' 'T5' 'T6'} {}(0x0) {}(0x0) {}(0x0) {}(0x0) {}(0x0)
%	}
%	b = colmerge(a, 'col1', {{'start1' 'start2'} {'stop1' 'stop2'}}, {'start' 'stop'})
%	b = {
%	      [1,1] =
%		1 1 5
%		1 6 7
%		2 2 4
%		2 8 9
%		3 1 2
%		3 5 6
%		4 3 5
%		4 8 9
%		5 3 7
%		5 8 9
%		6 2 3
%		6 4 6
%
%	      [1,2] =
%		thread
%		start
%		stop
%	}

function out = colmerge(table, colx, coly, y_name)
	%% First a few checking
	%% Is the table correct?
	check(table);
	%% Are parameters consistent?
	yname_size = size(y_name);
	yname_size = yname_size(2);
	coly_size = size(coly);
	coly_size = coly_size(2);
	%% Do we provide as many sources as we create columns?
	if yname_size != coly_size
		error(['Attempting to create ' int2str(yname_size) ' columns but provided ' int2str(coly_size) ' sources.']),
	end

	if yname_size < 1
		error('Must create at least one column');
	end

	%% Prepare the initial aliases
	aliases = alias(table, {colx});
	aliases = aliases{1};
	refs = ref(table, {colx});
	refs = refs{1};
	source_size = coly{1};
	source_size = size(source_size);
	yname_alias = {};
	yname_ref = {};
	for i = 1:yname_size
		sourcei_size = coly{i};
		sourcei_size = size(sourcei_size);

		%% Do we provide as many source column for each column created?
		if source_size != sourcei_size
			error(['Number of source columns to create column ''' y_name{i} ''' differs from number of source columns to create column ''' y_name{1} '''.']);
		end
	
		%% Are all source columns for one column to create of the same semantic?
		source1 = coly{i};
		source1 = source1{1};
		source1_alias = alias(table, {source1});
		source1_alias = source1_alias{1};
		source1_ref = ref(table, {source1});
		source1_ref = source1_ref{1};
		for j = 2:source_size
			sourcei = coly{i};
			sourcei = sourcei{i};
			sourcei_alias = alias(table, {sourcei});
			sourcei_alias = sourcei_alias{1};
			sourcei_ref = ref(table, {sourcei});
			sourcei_ref = sourcei_ref{1};
			if ! isequaln(source1_alias, sourcei_alias)
				error(['Sources to create column ''' yname{i} ''' have different aliases']);
			end
		end
		yname_alias = {yname_alias{:} source1_alias};
		yname_ref = {yname_ref{:} source1_ref};
	end
	aliases = {aliases yname_alias{:}};
	refs = {refs yname_ref{:}};

	%% Sort input table along x values
	table = orderby(table, {colx});
	matrix = data(table, {colx}, 0);
	matrix_size = size(matrix);

	%% These are all possible x values
	xvalues = data(groupby(table, {colx}, {}, {}), {colx}, 0);
	xvalues_size = size(xvalues);
	if xvalues_size != matrix_size
		error(['Values in column ''' colx ''' are not unique.']);
	end
	xvalues_size = xvalues_size(1);

	%% Start building the matrix
	matrix = [];

	%% Get the actual nume of source per column	
	source_size = source_size(2);

	%% For each x value
	for i = 1:xvalues_size
		submatrix = [];

		%% Iterate through columns to be created
		for j = 1:source_size
			%% Create a new line
			line = xvalues(i);

			%% For each column to create
			for k = 1:yname_size
				%% Fetch value from column
				col = coly{k};
				col = col{j};
				yvalue = data(where(table, [ colx ' == ' int2str(xvalues(i))]), {col}, 0);

				%% Append value to line
				line = [line yvalue];
			end
			submatrix = [submatrix ; line];
		end
		matrix = [matrix; submatrix];
	end

	out{1} = matrix;
	out{2} = {colx, y_name{:}};
	out{3} = aliases;
	out{4} = refs;
end

