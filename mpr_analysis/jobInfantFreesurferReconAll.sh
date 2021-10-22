#!/bin/sh
#
# The name of the job
#$ -N ifs-test-job-woo
#
# Join stdout and stderrL:
#$ -j y
#
# Set the amount of memory being requested
#$ -l h_vmem=32G

# Parse the arguments passed to the script as variables
INPUT=$1        # The input file to run infant_recon_all on
OUTDIR=$2       # The directory where the output of infant_recon_all should live
AGE=$3          # The age in days
FSL_VERSION=$4  # A string representing the FSL version "X.X.X"

# Print the inputs (remnant from debugging)
echo "Inputs to job:"
echo "Input image: $INPUT"
echo "Output directory: $OUTDIR"
echo "Age in days: $AGE"
echo "Freesurfer version: $FSL_VERSION"
echo

# Unload the FSL 5.3.0 module that's active by default
module unload freesurfer/5.3.0

# Set up environment variable and directory structure IFS is expecting
SUBJECTS_DIR=$(dirname $OUTDIR)
SUBJ=$(basename $OUTDIR)
echo $SUBJECTS_DIR
ls $SUBJECTS_DIR
ls $SUBJECTS_DIR/$SUBJ

# Copy the input image to the output directory
cp $INPUT $OUTDIR/mprage.nii.gz

# Convert age in days to age in months
AGE_MONTHS=$( awk -v var1=$AGE -v daysPerYear="365.25" -v monthsPerYear="12" 'BEGIN { print ( int(( var1 / daysPerYear ) * monthsPerYear ) ) }')
echo "Age in months: $AGE_MONTHS"

# Set up the Freesurfer 7.1.1 environment variables
FREESURFER_HOME=/cbica/projects/bgdimagecentral/freesurfer-7.1.1/
export FREESURFER_HOME

PATH="$PATH:$FREESURFER_HOME:/cbica/projects/bgdimagecentral/miniconda/bin/perl"
export PATH

# Set up Infant FreeSurfer
INFANT_FREESURFER=/cbica/projects/bgdimagecentral/freesurfer-infant/
bash $INFANT_FREESURFER/SetUpFreeSurfer.sh
source $INFANT_FREESURFER/FreeSurferEnv.sh
export SUBJECTS_DIR

# Run infant_recon_all
$INFANT_FREESURFER/bin/infant_recon_all --s $SUBJ --age $AGE_MONTHS --stats --ccseg

# Remove the mprage.nii.gz file from the output directory
rm $OUTDIR/mprage.nii.gz

