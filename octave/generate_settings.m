% This file is part of Freja.
% 
% Freja is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% Freja is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with Freja. If not, see <http://www.gnu.org/licenses/>.
%




%
% =============================================================================
%
%
%	Duplicates common settings for plots such as font size so each
%	plot gets its own individual parameters
%

%% Duplicate all default values as many times as necessary for each graph to get their own value
function generate_settings()
	global default_hatches default_hatch_pattern default_hatch_colors default_hatch_thickness default_pattern_thickness default_pattern_space default_colors default_markers default_thickness default_marker_size default_font default_font_size default_width default_height default_output_format default_output_prefix default_output_extension default_legend_location
	global default_legend_box default_scale default_group default_labels_angle default_bar_thickness default_style

	global hatches hatch_pattern hatch_colors hatch_thickness pattern_thickness pattern_space colors markers thickness marker_size font font_size width height output_format output_prefix output_extension legend_location
	global legend_box scale group labels_angle
	global plot_number style bar_thickness

	hatches = repmat({default_hatches}, [plot_number 1]);
	hatch_pattern = repmat({default_hatch_pattern}, [plot_number 1]);
	hatch_colors = repmat({default_hatch_colors}, [plot_number 1]);
	hatch_thickness = repmat({default_hatch_thickness}, [plot_number 1]);
	pattern_thickness = repmat({default_pattern_thickness}, [plot_number 1]);
	pattern_space = repmat({default_pattern_space}, [plot_number 1]);

	colors = repmat({default_colors}, [plot_number 1]);
	markers = repmat({default_markers}, [plot_number 1]);
	thickness = repmat({default_thickness}, [plot_number 1]);
	bar_thickness = repmat({default_bar_thickness}, [plot_number 1]);
	style = repmat({default_style}, [plot_number 1]);
	marker_size = repmat({default_marker_size}, [plot_number 1]);
	font = repmat({default_font}, [plot_number 1]);
	font_size = repmat({default_font_size}, [plot_number 1]);
	width = repmat({default_width}, [plot_number 1]);
	height = repmat({default_height}, [plot_number 1]);
	legend_location = repmat({default_legend_location}, [plot_number 1]);
	legend_box = repmat({default_legend_box}, [plot_number 1]);
	scale = repmat({default_scale}, [plot_number 1]);
	group = repmat({default_group}, [plot_number 1]);
	labels_angle = repmat({default_labels_angle}, [plot_number 1]);

	output_format = repmat({default_output_format}, [plot_number 1]);
	output_prefix = repmat({default_output_prefix}, [plot_number 1]);
	output_extension = repmat({default_output_extension}, [plot_number 1]);
end

