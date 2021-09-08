## grab args
args <- commandArgs(trailingOnly = TRUE)
rmarkdown::render("SingleCell_Combine_Annotate_and_Filter.Rmd", params = list(
    datafolder = args[1],
    scriptsfolder = args[2],
    cnr_npcs = args[3],
    cnr_vars_to_regress = args[4]
))