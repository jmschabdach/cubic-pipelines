#! /bin/bash
#
# The name of the job
#$ -N synthseg 
#
# Join stdout and stderrL:
#$ -j y
#
# Set the amount of memory being requested
#$ -l h_vmem=64G

# Required to set up the environment for SynthSeg to run correctly
source /cbica/projects/bgdimagecentral/miniconda3/etc/profile.d/conda.sh
source activate synthseg-2.0

INFN=$1
OUTDIR=$2

OUTFN=$OUTDIR/synthseg_segmentations.nii.gz
VOLSCSV=$OUTDIR/volumes.csv
QCCSV=$OUTDIR/qc_scores.csv
POSTFN=$OUTDIR/posterior_probability_maps.nii.gz

time python $SYNTHSEG_HOME/scripts/commands/SynthSeg_predict.py --i $INFN --o $OUTDIR --vol $VOLSCSV --qc $QCCSV --post $POSTFN --robust

echo "Job has finished running."
