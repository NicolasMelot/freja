

%
% =========================================================================
%
%	Function time_difference_thread
%
%	Compute the time difference in milliseconds before a start time t1
%	and a stop time t2, each of them represented as seconds and nanoseconds
%	according to the the clock_gettime() function used in c. Fetches the
%	required data at columns where relevant is data stored. This function
%	is specific to the feature to be computed in this experiment.
%	
%	
%	Parameters:
%	table:	Table being processed this function (table)
%	coln:	Column where the result will be written (string)
%	aux:	Any other data the user needs. Nothing here (undefined type).
%	out:	The new value to be written to the row (scalar).

function y = time_difference_thread(row, col, aux)
	NSEC_IN_SEC = 1000000000;
	MSEC_IN_SEC = 1000;
	NSEC_IN_MSEC = NSEC_IN_SEC / MSEC_IN_SEC;
	y = (((data(row, {'thread stop sec'}, 0) - data(row, {'thread start sec'}, 0)) .* NSEC_IN_SEC + data(row, {'thread stop nsec'}, 0) - data(row, {'thread start nsec'}, 0))) ./ NSEC_IN_MSEC;
end
