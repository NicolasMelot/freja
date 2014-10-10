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
      
      ## Reorder levels of factors in data.frame, and given them labels
      data.frame[,col] <- factor(data.frame[,col], levels=names(labels.list[[col]]), labels=as.character(labels.list[[col]]))
      
      ## Only keep factors actually used in the table
      data.frame[,col] <- factor(data.frame[,col])
    }
  }
  
  return(data.frame)
}

label = function(col, columns="columns", labels.list = labels)
{
  return(labels.list[[columns]][col])
}

