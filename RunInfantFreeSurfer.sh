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

module unload freesurfer/5.3.0

# Get the info about the image being reconalled
# Set up a temp directory in the structure IFS is expecting
# TODO: deal with subjects who have multiple scans
SUBJ_DIR="/cbica/projects/bgdimagecentral/Data/clinical-22q-mpr/22q-mpr/derivatives/mpr_preprocessed_3p0T_FSL6p0/sub-22q0147/ses-0991age00372/sub-22q0147_ses-0991age00372_acq-MPROriginal3p0PrecontrastHighResFromScanner20618_run-01_T1w/"
#INPUT_IMG="/cbica/projects/bgdimagecentral/Data/clinical-22q-mpr/22q-mpr/rawdata/sub-22q0147/ses-0991age00372/anat/sub-22q0147_ses-0991age00372_acq-MPROriginal3p0PrecontrastHighResFromScanner20618_run-01_T1w.nii.gz"
SUBJ="01"
OUTDIR="/cbica/projects/bgdimagecentral/testing/"

echo "\nChecking the SBIA_TMPDIR"
echo $SBIA_TMPDIR
echo "Contents of SBIA_TMPDIR\n"
ls -lt $SBIA_TMPDIR
echo "\n"

echo "Making SBIA_TMPDIR/$SUBJ"
if [ ! -d "$SBIA_TMPDIR/$SUBJ" ] ; then
    mkdir -p "$SBIA_TMPDIR/$SUBJ"
fi

echo "Making SBIA_TMPDIR/$SUBJ/out"
if [ ! -d "$SBIA_TMPDIR/$SUBJ/out" ] ; then
    mkdir -p "$SBIA_TMPDIR/$SUBJ/out/"
fi

# TODO: grab age from file name
AGE_DAYS="00372"
AGE="$((10#$AGE_DAYS))"
echo "Patient age in days: $AGE"

# Grab the mprage and put it in the temp directory
echo "Copying preprocessed_mpr.nii.gz to TMPDIR"
cp $SUBJ_DIR/preprocessed_mpr.nii.gz $SBIA_TMPDIR/$SUBJ/mprage.nii.gz
#cp $INPUT_IMG $SBIA_TMPDIR/$SUBJ/mprage.nii.gz

# Set up the Freesurfer environment variables
FREESURFER_HOME=/cbica/projects/bgdimagecentral/freesurfer-7.1.1/
export FREESURFER_HOME

PATH="$PATH:$FREESURFER_HOME:/cbica/projects/bgdimagecentral/miniconda/bin/perl"
export PATH

SUBJECTS_DIR=$SBIA_TMPDIR
echo $SUBJECTS_DIR
ls $SUBJECTS_DIR
ls $SUBJECTS_DIR/$SUBJ

# Set up Infant FreeSurfer
INFANT_FREESURFER=/cbica/projects/bgdimagecentral/freesurfer-infant/
bash $INFANT_FREESURFER/SetUpFreeSurfer.sh
source $INFANT_FREESURFER/FreeSurferEnv.sh
export SUBJECTS_DIR

# Set up a trap to copy any temp files in the case of failure
run_on_exit(){
    cp -r $SUBJECTS_DIR/$SUBJ $OUTDIR 
}
trap run_on_exit EXIT


# Run recon-all
$INFANT_FREESURFER/bin/infant_recon_all --s $SUBJ --age $AGE #--outdir "$TEMP/$SUBJ/out/"

# Copy stuff 
cp -r $SUBJECTS_DIR/$SUBJ $OUTDIR 

