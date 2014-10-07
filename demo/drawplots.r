#!/usr/bin/env Rscript

## Load ggplot
library(ggplot2)

## Read the data set
mydata = read.csv("table.m")

## Define a function to convert nanoseconds to seconds
nsec2sec = function(nsec)
{
  return(nsec / 1000000000)
}

## Reorder indexes for number of threads, so that sequential and overhead are first
mydata$nb_threads <- factor(mydata$nb_threads, levels = c("seq.", "over.", "2", "3", "4", "5"), labels=c("Sequential", "Overhead", "2", "3", "4", "5"))
## Remove unused levels in nb_threads
mydata$nb_threads <- factor(mydata$nb_threads)

## Create factors from a raw numeric variable
mydata$thread <- as.factor(mydata$thread)
## Give factors a human-readable label
mydata$thread <- factor(mydata$thread, labels=c("Thread 1 (seq.)", "Thread 1", "Thread 2", "Thread 3", "Thread 4"))
## Remove unused levels in nb_threads
mydata$thread <- factor(mydata$thread)

## create a ggplot base object, adds a bar diagram with individual thread performance
## then add two curves for both count experiments
plot = ggplot() +
  geom_bar(data=ddply(
    mydata[mydata$count == 100000000,], c("nb_threads", "thread"), summarize, mean=mean(
      thread_stop_sec + nsec2sec(thread_stop_nsec) - thread_start_sec - nsec2sec(thread_start_nsec))
    ),
    aes(nb_threads, mean, fill=factor(thread)),
    position="dodge") +
  geom_line(data=ddply(
    mydata, c("nb_threads", "count"), summarize, mean=mean(
      stop_time_sec + nsec2sec(stop_time_nsec) - start_time_sec - nsec2sec(start_time_nsec))
    ),
    aes(nb_threads, mean, group=count, color=as.character(count))) +
  geom_point()

## Save the plot as a svg file
ggsave(file="test.svg", plot=plot, width=8, height=6)