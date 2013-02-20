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
%	Function time_difference_thread
%
%	Compute the time difference in milliseconds before a start time t1
%	and a stop time t2, each of them represented as seconds and nanoseconds
%	according to the the clock_gettime() function used in c. Fetches the
%	required data from row at indexes where it is known there is relevant
%	data stored. This function is specific to the feature to be computed
%	in this experiment.
%	
%	
%	Parameters:
%	row:	Row being process by this call to the function (one line table)
%	col:	Column where the result will be written (string)
%	out:	The new value to be written to the row (scalar).

function y = time_difference_thread(row, col)
	NSEC_IN_SEC = 1000000000;
	MSEC_IN_SEC = 1000;
	NSEC_IN_MSEC = NSEC_IN_SEC / MSEC_IN_SEC;
% entropy nb_threads ct try thread start_time_sec start_time_nsec stop_time_sec stop_time_nsec thread_start_sec thread_start_nsec thread_stop_sec thread_stop_nsec
	y = (((data(row, {'thread_stop_sec'}, 0) - data(row, {'thread_start_sec'}, 0)) * NSEC_IN_SEC + data(row, {'thread_stop_nsec'}, 0) - data(row, {'thread_start_nsec'}, 0))) / NSEC_IN_MSEC;
end
