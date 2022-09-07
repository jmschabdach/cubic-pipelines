#!/bin/bash
#
# Usage:
# bash job_submitter.sh /path/to/bidsdir
#

DIR=$1

BASE=/cbica/projects/bgdimagecentral/Projects/synthseg_job_code

# For each subject in the BIDs directory
for SUBJECT in $DIR/sub-* ; do
    


    # For each session for the subject 
    for SESSION in $SUBJECT/ses-* ; do

        # For each scan file from the session
        for FN in $SESSION/anat/*.nii.gz ; do 
            echo "mpr"
            # Check that an MPR exists in the session 
            if [[ ${FN,,} == *"mpr"* ]] ; then      
                 # Set up the output directory 
                 OUTDIR="${FN/rawdata/derivatives/synthseg_2.0}"
                 OUTDIR="${OUTDIR/anat/}"
                 OUTDIR=${OUTDIR%%.nii.gz}

                 # If the output directory doesn't exist, then make it
                 if [ ! -d $OUTDIR ] ; then
                     echo "Initial job run"
                     mkdir -p $OUTDIR
                     # Submit the SynthSeg 2.0 job
                     qsub $BASE/jobSynthSeg.sh $FN $OUTDIR
                 else 
                     echo "Error: the output directory already exists. No job submitted."
                 fi 
            fi 
        done
    done
done
