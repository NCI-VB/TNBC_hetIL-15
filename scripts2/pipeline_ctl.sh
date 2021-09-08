#!/bin/bash

ARGPARSE_DESCRIPTION="Create all files required to generate a MultiQC report"
source /opt2/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('--program',required=True, help='program to execute. options: all, single_cell, nanostring')
parser.add_argument('--data_dir',required=False, default='/data2', help='path to the qc folder')
parser.add_argument('--scriptsfolder',required=False, default='/opt2', help='folder where the scripts are... used for debuging without rebuilding the docker')

parser.add_argument('--cellranger_data',required=False, default='/input_data/C_TUMOR_CD11.protein.h5,/input_data/IL15_TUMOR_CD11.protein.h5', help='Comma-separated list of cellranger h5 files. These should be located in datafolder.')
parser.add_argument('--sample_names',required=False, default='Control,Treated', help='Comma-separated list of names for cellranger_data.')
parser.add_argument('--sc_filter_mincells',required=False, default='3', help='Filter out genes found in less than this number of cells.')
parser.add_argument('--sc_filter_mingenes',required=False, default='200', help='Filter out cells with less than this number of genes found in them. ')
parser.add_argument('--sc_filter_mincomplexity',required=False, default='0.5', help='Minimum number of genes detected per UMI.')
parser.add_argument('--sc_filter_minmad_genes',required=False, default='3', help='How many Median Absolute Deviations do you want to use to filter out cells with too many genes?')
parser.add_argument('--sc_filter_minmad_mito',required=False, default='3', help='How many Median Absolute Deviations do you want to use to filter out cells with too high a percentage of mitochondrial RNA?')
parser.add_argument('--sc_filter_max_genes',required=False, default='2500', help='How many Median Absolute Deviations do you want to use to filter out cells with too many genes?')
parser.add_argument('--qc_vars_to_regress',required=False, default='S.Score,G2M.Score', help='')
parser.add_argument('--qc_npcs',required=False, default='25', help='')

parser.add_argument('--cnr_npcs',required=False, default='18', help='')
parser.add_argument('--cnr_vars_to_regress',required=False, default='S.Score,G2M.Score', help='')
EOF

program=$PROGRAM
data_dir=$DATA_DIR
scriptsfolder=$SCRIPTSFOLDER

if [[ $program =~ ^(all|nanostring|single_cell)$ ]]; then
	if [ $program == 'nanostring' ] || [ $1 == 'all' ]
	then
		echo "Running Nanostring..."
		/opt2/NanostringCall.R
	fi

	if [ $program == 'single_cell' ] || [ $1 == 'all' ]
	then
		echo "Running Single Cell..."
		if [ ! -f ${data_dir}/filtered_and_qc.rds ]; then
			Rscript /opt2/sc_filter_and_qc_call.R \
				$data_dir \
				$scriptsfolder \
				$CELLRANGER_DATA \
				$SAMPLE_NAMES \
				$SC_FILTER_MINCELLS \
				$SC_FILTER_MINGENES \
				$SC_FILTER_MINCOMPLEXITY \
				$SC_FILTER_MINMAD_GENES \
				$SC_FILTER_MINMAD_MITO \
				$QC_VARS_TO_REGRESS \
				$QC_NPCS
		fi

		if [ ! -f "${data_dir}/merged_and_filtered_so.rds" ]; then
			Rscript /opt2/sc_commbine_annotate_filter_call.R \
				$data_dir \
				$scriptsfolder \
				$CNR_NPCS \
				$CNR_VARS_TO_REGRESS
		fi
	fi
else
    printf "Usage: docker run -v <data_dir>:/data2 --rm karaliota_il15:v2.0 [all|nanostring|single_cell]\n"
fi
