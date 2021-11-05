#!/bin/bash
##SBATCH --time=5:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8  
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=deepTools_atac
#SBATCH --partition=short
#SBATCH --array=0-5

# Program configuration
__author__='Nadia Goué'
__email__='brice.pertuisot@etu.uca.fr'
__credits__=["Nadia Goué"]
__license__='GPL3'
__maintainer__='Nadia Goué'
__status__='Development'
__version__='0.0.1'

echo 'DeepTools - User-friendly tools for exploring deep-sequencing data; BAM files analysis'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

#Set up whatever package we need to run with
module purge
module load gcc/4.8.4 python/2.7.9 numpy/1.9.2 samtools/1.3 deepTools/3.1.2



echo "Set up directories ..." >&2

#Set up the temporary directory

SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/DeepTools
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

#Set up data directory
DATA_DIR="$HOME"/results/atacseq/MarkDuplicates

echo "Set up 1 array with input names files for DeepTools" >&2

tab=($(find "$DATA_DIR" -type f -name "*_lessDup.bam"))

# Current filename
#SHORTNAME=$(basename "${tab[$SLURM_ARRAY_TASK_ID]}".bam )
#echo "shortname = $SHORTNAME" >&2

#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2


# !!!!!!!!!!!!!!!!!!!à verif $DATA_DIR/*.bam ok
plotCoverage --bamfiles $DATA_DIR/*/*.bam\
            --plotFile PlotCoverage \
            --smartLabels \
            --outRawCounts coverageRawCount.tab \
            --plotFileFormat pdf
#--skipZeros \
#-T "DeepTools plotCoverage" \




#multiBamSummary bins --bamfiles file1.bam file2.bam -o results.npz

# !!!!!!!!!!!!!!!!!!!à verif $DATA_DIR/*.bam ok
multiBamSummary bins --bamfiles $DATA_DIR/*/*.bam\
                        -o resultsMultiBamSummary.npz



plotCorrelation     -in resultsMultiBamSummary.npz \
    --corMethod spearman --skipZeros \
    --whatToPlot heatmap --colorMap RdYlBu --plotNumbers \
    -o heatmap_SpearmanCorr_readCounts.png   \
    --outFileCorMatrix "$OUTPUT"/SpearmanCorr_readCounts.tab

#   -T "Spearman Correlation of Read Counts" \


# Move results in user one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2

