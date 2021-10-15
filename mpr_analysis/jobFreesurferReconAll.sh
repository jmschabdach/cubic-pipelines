#!/bin/sh
#
# The name of the job
#$ -N reconall
#
# Join stdout and stderrL:
#$ -j y
#
# Set the amount of memory being requested.
#$ -l h_vmem=8G

#source $FREESURFER_HOME/SetUpFreeSurfer.sh

OUTDIR=$1     # string specifying where the output of recon-all should live when it's done
INPUT=$2      # file name
SUBJ=$3       # identifier string for the subject (sub-XXXX)
FSLVERSION=$4 # string

BASE=/cbica/projects/bgdimagecentral/Projects/mpr_analysis

source ~/miniconda3/etc/profile.d/conda.sh

echo "Inputs:"
echo "OUTDIR: $OUTDIR"
echo "INPUT: $INPUT"
echo "SUBJ: $SUBJ"
echo "FSLVERSION: $FSLVERSION"

if [[ $FSLVERSION == "6.0.0" ]] ; then
    module unload freesurfer/5.3.0
    module load freesurfer/6.0.0
elif [[ $FSLVERSION == "5.3.0" ]] ; then
    module unload freesurfer/6.0.0
    module load freesurfer/5.3.0
elif [[ $FSLVERSION == "7.1.1" ]] ; then
    echo "Want FS 7.1.1"
    module unload freesurfer/6.0.0
    module unload freesurfer/5.3.0

    # load FS 7.1.1 from local install
    FREESURFER_HOME=/cbica/projects/bgdimagecentral/freesurfer-7.1.1/
    export FREESURFER_HOME

    PATH="$PATH:$FREESURFER_HOME:/cbica/projects/bgdimagecentral/miniconda/bin/perl"
    export PATH

    source $FREESURFER_HOME/FreeSurferEnv.sh
else
    echo "Something wrong with FSLVERSION $FSLVERSION"
fi

echo "Scratch directory: "

# Run the preprocessing
INTERIM=$OUTDIR/preprocessed_mpr.nii.gz
# do I need to copy the input image into the working directory?
cp $INPUT $OUTDIR
bash $BASE/preprocWashUACPCAlignment.sh --workingdir=$OUTDIR --in=$INPUT --out=$INTERIM --omat="premat.mat"

# Run recon-all 
recon-all -subject $SUBJ -i $INTERIM -all -target $SUBJECTS_DIR/fsaverage
 
# # Job ended, move stuff back
# cp -r $SUBJECTS_DIR/$SUBJ/* $OUTDIR
