#!/bin/sh
#
# The name of the job
#$ -N jmy-preproc-reconall-fs-job
#
# Join stdout and stderrL:
#$ -j y
#
# Set the amount of memory being requested
# -l h_vmem=32G
#$ -l h_vmem=8G

ORIGMPR=$1    # /cbica/projects/bgdimagecentral/Data/clinical.../mpr.../rawdata/sub/ses/anat/fn
AGEDAYS=$2
FSVERSION=$3

BASE=/cbica/projects/bgdimagecentral/Projects/mpr_analysis

# 1. Get FSVERSION correct
if [[ $FSVERSION == "5.3.0" ]] ; then
    module unload freesurfer/6.0.0
    module load freesurfer/5.3.0
elif [[ $FSVERSION == "6.0.0" ]] ; then
    module unload freesurfer/5.3.0
    module load freesurfer/6.0.0
elif [[ $FSVERSION == "7.1.1" ]] ; then
    module unload freesurfer/5.3.0
    module unload freesurfer/6.0.0
    
    # Set up the Freesurfer environment variables
    FREESURFER_HOME=/cbica/projects/bgdimagecentral/freesurfer-7.1.1/
    export FREESURFER_HOME

    PATH="$PATH:$FREESURFER_HOME:/cbica/projects/bgdimagecentral/miniconda/bin/perl"
    export PATH
fi


# 2. Set up variables
SES=$(basename $(dirname $(dirname $ORIGMPR)))  # Get the name of the directory 2 levels up
SUB=$(basename $(dirname $(dirname $(dirname $ORIGMPR))))  # Get the name of the directory 3 levels up
tmp=$(basename $ORIGMPR)  # Get the name of the file
IMG="${tmp/.nii.gz/}"  # Pull the .nii.gz extension off of the file


# 3. Set up the working directory
SCRATCH_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)  # Generate a random 16 character string
WORKBASE=$SBIA_TMP/$SCRATCH_ID
mkdir $WORKBASE

WORKDIR=$WORKBASE/rawdata/$SUB/$SES/anat/
mkdir -p $WORKDIR

PREPROC_DIR=$WORKBASE/derivatives/preproc/$SUB/$SES/$IMG
mkdir -p $PREPROC_DIR

RECON_DIR=$WORKBASE/derivatives/reconall-$FSVERSION/$SUB/$SES/$IMG/
mkdir -p $RECON_DIR

OUT_DIR=$

# Copy over the fsaverage template
cp -r /cbica/projects/bgdimagecentral/fsaverage/ $WORKBASE

# Set a trap to copy any temp files 
run_on_exit(){
    cp -r $WORKBASE/derivatives $OUT_DIR
}
trap run_on_exit EXIT


# 4. Copy the original file to the working directory
cp $ORIGMPR $WORKDIR


# 5. bash the preprocessing script
bash $BASE/preprocWashUACPCAlignment.sh --workingdir=$PREPROC_DIR --in=$WORKDIR/ --out=$PREPROC_DIR/preprocessed_mpr.nii.gz --omat="premat.mat"


## 6. recon all
# recon-all -subject $SUBJ -i $PREPROC_DIR.preprocessed_mpr.nii.gz -all -target $WORKDIR/fsaverage

# # Set up Infant FreeSurfer
# INFANT_FREESURFER=/cbica/projects/bgdimagecentral/freesurfer-infant/
# bash $INFANT_FREESURFER/SetUpFreeSurfer.sh
# source $INFANT_FREESURFER/FreeSurferEnv.sh
# export SUBJECTS_DIR
# $INFANT_FREESURFER/bin/infant_recon_all --s $SUBJ --age $AGE #--outdir "$TEMP/$SUBJ/out/"
