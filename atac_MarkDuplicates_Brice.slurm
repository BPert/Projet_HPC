#!/bin/bash
##SBATCH --time=5:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8  
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=markDupl_atac
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

echo 'MarkDuplicates ; Identifies duplicate reads'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

#Set up whatever package we need to run with
module purge
module load gcc/8.1.0 java/oracle-1.11.0_11 picard/2.18.25 samtools/1.9


echo "Set up directories ..." >&2

#Set up the temporary directory

SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/MarkDuplicates
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

#Set up data directory
DATA_DIR="$HOME"/results/atacseq/bowtie2

echo "Set up 1 array with input names files for MarkDuplicates" >&2

tab=($(find "$DATA_DIR" -type f -name "*_trim_mapped_sorted_q2.bam"))
echo "tab = " >&2
printf '%s\n' "${tab[@]}" >&2

# Current filename  "$(basename "${tab_fwd[i]::-9}")"
SHORTNAME=$(basename "${tab[$SLURM_ARRAY_TASK_ID]::-4}")
echo "shortname = $SHORTNAME" >&2

#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

#-jar /opt/apps/picard-2.18.25/picard.jar MarkDuplicates

#java -jar picard.jar MarkDuplicates \
java -jar /opt/apps/picard-2.18.25/picard.jar MarkDuplicates \
      I="${tab[$SLURM_ARRAY_TASK_ID]}" \
      O="$SHORTNAME"_lessDup.bam \
      M="$SHORTNAME"_marked_dup_metrics.txt \
      REMOVE_DUPLICATES=true


echo "Indexing _lessDup.bam ..." >&2
samtools index -b "$SHORTNAME"_lessDup.bam

# Move results in user one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2
