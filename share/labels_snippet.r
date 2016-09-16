# Copyright 2015 Nicolas Melot
#
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

append_combinations = function(data.frame, comb = combination)
{
  ## Append keys for column combination
  for(col in names(comb))
  {
    paste_str = paste(sep = "", "data.frame[,\"", col, "\"] = paste(sep = \".\"")
    for(src in as.character(comb[[col]]))
    {
      paste_str = paste(sep = "", paste_str, ", data.frame[,\"", src, "\"]")
    }
    paste_str = paste(sep = "", paste_str, ")")
  
    eval(parse(text = paste_str))
    data.frame[,col] <- as.factor(data.frame[,col])
  }

  return(data.frame)
}

apply_labels = function(data.frame, labels.list = labels, comb = combination)
{
  data.frame = append_combinations(data.frame, comb)

  ## Change values with their human-friendly aliases  
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

freja_colors = function(data.frame, col, colors.list = colors, default = c("#BB0000", "#66BB00", "#0000BB"), comb = combination)
{
  out = levels(interaction(data.frame[,col], sep = "."))
  col = paste(col, collapse = sep)

  def = colorRampPalette(default)(abs(length(out) - length(colors[[col]])))
  missing = 1

  lst = list()
  for(i in out)
  {
    if(i %in% names(colors.list[[col]]))
    {
      lst = c(lst, colors.list[[col]][[i]])
    }
    else
    {
      warning(paste(c("Could not find color for value ", as.character(i), "."), collapse = ""));
      out[[i]] = def[i]
      lst = c(lst, def[missing])
      missing = missing + 1
    }
  }

  lst = c(as.character(lst), "#000000")
  return(as.character(lst))
}

