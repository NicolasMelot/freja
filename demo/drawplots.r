#!/usr/bin/env Rscript

## Load packages
library(ggplot2)
library(plyr)

## Read the data set
data.frame = read.csv("table.csv")

## Load labels and labelling functions
source("labels.r")

## Define a function to convert nanoseconds to seconds
nsec2sec = function(nsec)
{
  return(nsec / 1000000000)
}

## create a ggplot base object, adds a bar diagram with individual thread performance
## then add two curves for both count experiments
plot = ggplot() +
  geom_bar(data = ddply(
    apply_labels(data.frame[data.frame$count == 100000000,]), c("nb_threads", "thread"), summarize, mean = mean(
      thread_stop_sec + nsec2sec(thread_stop_nsec) - thread_start_sec - nsec2sec(thread_start_nsec))
    ),
    aes(nb_threads, mean, fill = thread),
    position = "dodge", stat = "identity") +
  geom_line(data = ddply(
    apply_labels(data.frame), c("nb_threads", "count"), summarize, mean = mean(
      stop_time_sec + nsec2sec(stop_time_nsec) - start_time_sec - nsec2sec(start_time_nsec))
    ),
    aes(nb_threads, mean, group = count, color = count), size=1) +
  guides(fill=guide_legend(title="Thread"), colour=guide_legend(title="Problem size"), point=guide_legend(title="Point")) +
  geom_point() +
  ylab("Running time in seconds") +
  xlab(label("nb_threads")) +
  ggtitle("Running time for empty loops") + 
  scale_fill_manual(values = colorRampPalette(c("#FF0000", "#000000"))(5)) +
  scale_colour_manual(values = c("#771C19", "#B6C5CC"))

## Save the plot as a svg file
ggsave(file="test.svg", plot=plot, width=8, height=6)