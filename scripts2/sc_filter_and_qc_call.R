## grab args
args <- commandArgs(trailingOnly = TRUE)
rmarkdown::render("SingleCell_Filter_and_QC.Rmd", params = list(
    data_dir = args[1],
	scriptsfolder = args[2],
	cellranger_data = args[3],
	sample_names = args[4],
	sc_filter_mincells = args[5],
	sc_filter_mingenes = args[6],
	sc_filter_mincomplexity = args[7],
	sc_filter_minmad_genes = args[8],
	sc_filter_minmad_mito = args[9],
	qc_vars_to_regress = args[10],
	qc_npcs = args[11]
))