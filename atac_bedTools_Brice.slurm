#!/bin/bash
##SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8  
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=bedTools_atac
#SBATCH --partition=short
#SBATCH --array=0-2

# Program configuration
__author__='Nadia Goué'
__email__='brice.pertuisot@etu.uca.fr'
__credits__=["Nadia Goué"]
__license__='GPL3'
__maintainer__='Nadia Goué'
__status__='Development'
__version__='0.0.1'

echo 'bedtools : a powerful toolset for genome arithmetic. '
echo 'bedtools intersect ; searching for uniques and common accessibility sites between the different cellular stage.'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

#Set up whatever package we need to run with
module purge
module load gcc/4.8.4 bedtools/2.27.1

#Set up the temporary directory
echo "Set up directories ..." >&2

SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/bedTools
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

#Set up data directory
DATA_DIR="$HOME"/results/atacseq/MACS2

#set up arrays
echo "set up arrays" >&2

tab0h=($(find "$DATA_DIR" -type f -name "*_0h_*_macs2_atacSeq_summits.bed" ))
echo "tab0h= " >&2
printf '%s\n' "${tab0h[@]}" >&2

tab24h=($(find "$DATA_DIR" -type f -name "*_24h_*_macs2_atacSeq_summits.bed" ))
echo "tab24h= " >&2
printf '%s\n' "${tab24h[@]}" >&2

SHORTNAME=$(basename "${tab0h[$SLURM_ARRAY_TASK_ID]::-55}" | cut -c 8- )
echo "SHORTNAME=$SHORTNAME" >&2

#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "Common peaks between stage 0h and 24h:" >&2
bedtools intersect -a "${tab0h[$SLURM_ARRAY_TASK_ID]}" -b "${tab24h[$SLURM_ARRAY_TASK_ID]}" > "$SCRATCHDIR"/"$SHORTNAME"_0h_24h_common_peaks.bed

echo "unique peaks for stage 0h:" >&2
bedtools intersect -v -a "${tab0h[$SLURM_ARRAY_TASK_ID]}" -b "${tab24h[$SLURM_ARRAY_TASK_ID]}" > "$SCRATCHDIR"/"$SHORTNAME"_0h_unique_peaks.bed

echo "unique peaks for stage 24h:" >&2
bedtools intersect -v -a "${tab24h[$SLURM_ARRAY_TASK_ID]}" -b "${tab0h[$SLURM_ARRAY_TASK_ID]}" > "$SCRATCHDIR"/"$SHORTNAME"_24h_unique_peaks.bed

# Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"
echo "Stop job : "`date` >&2

