% Number of plots to be generated 
global plot_number = 4;

%% Duplicate all default values as many times as necessary for each graph to get their own value
function make_settings()
	global default_hatches default_hatch_pattern default_hatch_colors default_hatch_thickness default_pattern_thickness default_pattern_space default_colors default_markers default_thickness default_marker_size default_font default_font_size default_width default_height default_output_format default_output_prefix default_output_extension default_legend_location;
	global hatches hatch_pattern hatch_colors hatch_thickness pattern_thickness pattern_space colors markers thickness marker_size font font_size width height output_format output_prefix output_extension legend_location;
	global plot_number;

	hatches = repmat({default_hatches}, [plot_number 1]);
	hatch_pattern = repmat({default_hatch_pattern}, [plot_number 1]);
	hatch_colors = repmat({default_hatch_colors}, [plot_number 1]);
	hatch_thickness = repmat({default_hatch_thickness}, [plot_number 1]);
	pattern_thickness = repmat({default_pattern_thickness}, [plot_number 1]);
	pattern_space = repmat({default_pattern_space}, [plot_number 1]);

	colors = repmat({default_colors}, [plot_number 1]);
	markers = repmat({default_markers}, [plot_number 1]);
	thickness = repmat({default_thickness}, [plot_number 1]);
	marker_size = repmat({default_marker_size}, [plot_number 1]);
	font = repmat({default_font}, [plot_number 1]);
	font_size = repmat({default_font_size}, [plot_number 1]);
	width = repmat({default_width}, [plot_number 1]);
	height = repmat({default_height}, [plot_number 1]);
	legend_location = repmat({default_legend_location}, [plot_number 1]);

	output_format = repmat({default_output_format}, [plot_number 1]);
	output_prefix = repmat({default_output_prefix}, [plot_number 1]);
	output_extension = repmat({default_output_extension}, [plot_number 1]);
end

%% Default graph parameters
%% Seems like octave support for alternate hatch pattern is broken. Only '-' works
%global default_hatches = {'-' '--' ':' '-.' 'none' '-' '--' ':' '-.'};
global default_hatches = {'-' '-' '-' '-' '-' '-' '-' '-' '-'};
global default_hatch_pattern = {'swne' 'nwse' 'hrzt' 'vert' 'cross' 'swne' 'nwse' 'hrzt' 'vert'};
global default_hatch_colors = {[0 0 0] [0 0 1] [0 1 0] [0 1 1] [1 0 0] [1 0 1] [1 1 0] [1 1 1] [0 0 0]};
global default_hatch_thickness = 0.7;
global default_pattern_thickness = 2;
global default_pattern_space = 1;

global default_colors = {[1 0 0] [1 0 1] [0 0 1] [0 0 0] [0 0.5 0.5] [0 0.5 0] [0 0 0.5] [0.5 0 0.5] [0.5 0 0]};
global default_markers = {'o' '^' '.' 'x' '>' '<' 'v' '*'};
global default_thickness = 2;
global default_marker_size = 5;
global default_font = 'MgOpenModernaBold.ttf';
global default_font_size = 8;
global default_width = 800;
global default_height = 400;

global default_output_format='epsc';
global default_output_prefix='';
global default_output_extension='eps';
global default_legend_location='northeast';

%% Declaration for default graph-specific parameters
global hatches;
global hatch_pattern;
global hatch_colors;
global hatch_thickness;
global pattern_thickness;
global pattern_space;

global colors;
global markers;
global thickness;
global marker_size;
global font;
global font_size;
global width;
global height;

global output_format;
global output_prefix;
global output_extension;
global legend_location;

%% Generate settings for each plot to be generated
make_settings

%% Give specific graphs a particular value
%% Gantt chart (graph #4) gets higher than default height
height{4} = 600;
