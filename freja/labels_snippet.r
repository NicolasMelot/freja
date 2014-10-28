apply_labels = function(data.frame, labels.list = labels)
{  
  for(col in names(labels.list)[names(labels.list) != "columns"])
  {
    ## Only apply the transformation if the column exists, otherwise skip the column
    if(col %in% names(data.frame))
    {
      ## If the corresponding column in the data frame is not a factor, then make it one
      if(!is.factor(data.frame[,col]))
      {
        data.frame[,col] <- as.factor(data.frame[,col])
      }
      
      ## Get levels and respective labels as from the label list
      levels = names(labels.list[[col]])
      labels = as.character(labels.list[[col]])
      
      ## Pad missing labels with values as they appear in data
      if(!all(levels(data.frame[,col]) %in% names(labels.list[[col]])))
      {
        ## Levels of data.frame, where levels that appear in labels appear first and ordered as in the list
        levels = unique(c(names(labels.list[[col]]), levels(data.frame[,col])))
        #levels = names(factor(data.frame[,col], levels=unique(c(labels.list[[col]], levels(data.frame[,col])))))
        
        ## Concatenate labels with Levels of data.frame that are not in the list of labels
        labels = c(as.character(labels.list[[col]]), levels(factor(data.frame[,col][!data.frame[,col] %in% names(labels.list[[col]])])))
      }

      ## Reorder levels of factors in data.frame, and give them labels
      data.frame[,col] <- factor(data.frame[,col], levels=levels, labels=labels)
      
      ## Only keep factors actually used in the table
      data.frame[,col] <- factor(data.frame[,col])
    }
  }
  
  return(data.frame)
}

label = function(col, columns="columns", labels.list = labels)
{
  if(col %in% names(labels.list[[columns]]))
    return(labels.list[[columns]][col])
  else
    return(col)
}

