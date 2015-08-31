# This file is part of Freja.
#
# Freja is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Freja is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Freja. If not, see <http://www.gnu.org/licenses/>.
#


#!/usr/bin/env Rscript

## Load packages
library(ggplot2)
library(plyr)

options(error = function() {traceback(2); dump.frames; stopifnot(FALSE)})

## Read the data set
data.frame = read.csv("table.csv")

## Load labels and labeling functions
source("labels.r")

## Define a function to convert nanoseconds to seconds
nsec2sec = function(nsec)
{
  return(nsec / 1000000000)
}

## Compute the execution time for each run of the experiment
data.frame = ddply(
  data.frame, c("nb_threads", "thread", "count", "try"), summarize,
  thread_time = 
    thread_stop_sec + nsec2sec(thread_stop_nsec) - thread_start_sec - nsec2sec(thread_start_nsec),
  global_time = 
    stop_time_sec + nsec2sec(stop_time_nsec) - start_time_sec - nsec2sec(start_time_nsec)
)

## Compute mean and standard deviation
data.frame = ddply(
  data.frame, c("nb_threads", "thread", "count"), summarize,
  thread_mean_time = mean(thread_time),
  global_mean_time = mean(global_time),
  thread_time_std = sd(thread_time),
  global_time_std = sd(global_time)
)

## Create a simple plot with ggplots
plot = ggplot() +
  geom_line(data = apply_labels(data.frame),
            aes(nb_threads, global_mean_time, group = count, color = count),
            size=1) +
  geom_point() +
  guides(fill=guide_legend(title="Thread"), colour=guide_legend(title="Problem size"), point=guide_legend(title="Point")) +
  ylab("Running time in seconds") +
  xlab(label("nb_threads")) +
  ggtitle("Running time for empty loops") + 
  scale_fill_manual(values = colorRampPalette(c("#FF0000", "#000000"))(9)) +
  scale_colour_manual(values = c("#771C19", "#B6C5CC"))
## Save the plot as a svg file
ggsave(file="1_timing.svg", plot=plot, width=8, height=6)

## Overlay plot + errorbar + bars together for the lower number of iterations
plot = ggplot() +
  geom_bar(data = apply_labels(data.frame[data.frame$count == 100000000,]),
    aes(nb_threads, thread_mean_time, fill = thread),
    position = "dodge", stat = "identity") +
  geom_line(data = apply_labels(data.frame),
    aes(nb_threads, global_mean_time, group = count, color = count),
    size=1) +
  geom_errorbar(data = apply_labels(data.frame),
                aes(nb_threads, ymax=global_mean_time + global_time_std, ymin=global_mean_time - global_time_std, group = count, color= count)
                ) +
  geom_point() +
  guides(fill=guide_legend(title="Thread"), colour=guide_legend(title="Problem size"), point=guide_legend(title="Point")) +
  ylab("Running time in seconds") +
  xlab(label("nb_threads")) +
  ggtitle("Running time for empty loops") + 
  scale_fill_manual(values = colorRampPalette(c("#FF0000", "#000000"))(9)) +
  scale_colour_manual(values = c("#771C19", "#B6C5CC"))
## Save the plot as a svg file
ggsave(file="2_timing-100.svg", plot=plot, width=8, height=6)

## Overlay plot + errorbar + bars together for the lower number of iterations
plot = ggplot() +
  geom_bar(data = apply_labels(data.frame[data.frame$count == 200000000,]),
  aes(nb_threads, thread_mean_time, fill = thread),
  position = "dodge", stat = "identity") +
  geom_line(data = apply_labels(data.frame), 
            aes(nb_threads, global_mean_time, group = count, color = count),
            size=1) +
  geom_errorbar(data = apply_labels(data.frame),
                aes(nb_threads, ymax=global_mean_time + global_time_std, ymin=global_mean_time - global_time_std, group = count, color= count)
  ) +
  guides(fill=guide_legend(title="Thread"), colour=guide_legend(title="Problem size"), point=guide_legend(title="Point")) +
  geom_point() +
  ylab("Running time in seconds") +
  xlab(label("nb_threads")) +
  ggtitle("Running time for empty loops") + 
  scale_fill_manual(values = colorRampPalette(c("#FF0000", "#000000"))(9)) +
  scale_colour_manual(values = c("#771C19", "#B6C5CC"))

## Save the plot as a svg file
ggsave(file="3_timing-200.svg", plot=plot, width=8, height=6)
