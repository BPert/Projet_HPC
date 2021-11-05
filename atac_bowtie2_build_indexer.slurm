#!/bin/bash
#SBATCH --time=6:50:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=Bowt2_build_atac
#SBATCH --partition=short


# Program configuration
__author__='Nadia Goué'
__email__='brice.pertuisot@etu.uca.fr'
__credits__=["Nadia Goué"]
__license__='GPL3'
__maintainer__='Nadia Goué'
__status__='Development'
__version__='0.0.1'

echo 'bowtie2-build indexer'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

IFS=$'\n\t'

# Upload whatever required packages
module purge
module load gcc/8.1.0 bowtie2/2.3.4.3


echo "Set up directories ..." >&2

# Set up data directory
DATA_DIR="/home/users/student22/data/Mus_musculus"

# Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

OUTPUT="$HOME"/results/atacseq/bowtie_build
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"


#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

bowtie2-build -f "$DATA_DIR"/all.fasta 'Ind_GRCm38_p6'


# Move results in one's directory
mv  "$SCRATCHDIR"/* "$OUTPUT"
rm -rf "$SCRATCHDIR"

echo "Stop job : "`date` >&2
