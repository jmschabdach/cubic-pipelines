DATADIR=$1
FSVERSION=$2

BASE=/cbica/projects/bgdimagecentral/Projects/mpr_analysis

# for subject in directory
for subj in $DATADIR/sub-* ; do
    # for session in directory
    SUBJID=$(basename $subj)
    for session in $subj/ses-* ; do
        # get the age of the subject at the time of the scan
        sesIdStr=${session#*ses-}
        ageStr=${sesIdStr#*age}
        ageNum=$((10#$ageStr))


        # Check that an MPR exists in the session 
        for fn in $session/anat/*.nii.gz ; do 
            if [[ ${fn,,} == *"mpr"* ]] ; then      # Cool an MPR exists
           
                # Set up variables needed for the preprocessing and recon-all
 
                # if the age is less than 2 years
                if [ $ageNum -lt 731 ] ; then
                    # start the infant freesurfer job
                    OUTDIR="$(dirname $DATADIR)/mpr_ifs_reconall/$SUBJID/$(basename $session)/$(basename -s .nii.gz $fn)"
#                    qsub $BASE/jobInfantFreesurferReconAll.sh $fn $ageNum $FSVERSION
                # else if the age is less than 3 years
                elif [ $ageNum -lt 1096 ] ; then
                    # start both an infant freesurfer job and a regular freesurfer job
                    OUTDIR="$(dirname $DATADIR)/mpr_ifs_reconall/$SUBJID/$(basename $session)/$(basename -s .nii.gz $fn)"
#                    qsub $BASE/jobInfantFreesurferReconAll.sh $fn $ageNum $FSVERSION

                    # start a regular freesurfer job 
                    OUTDIR="${fn/rawdata/derivatives/mpr_fs_reconall_$FSVERSION}"
                    OUTDIR="$(dirname $OUTDIR)/$(basename -s .nii.gz $OUTDIR)"

                    if [ ! -d $OUTDIR ] ; then
                        mkdir -p $OUTDIR
                    fi

                    echo "$OUTDIR $fn $SUBJID $FSVERSION"
                    qsub $BASE/jobFreesurferReconAll.sh $OUTDIR $fn $SUBJID $FSVERSION

                # else age > 3 years
                else 
                    # start a regular freesurfer job 
                    OUTDIR="${fn/rawdata/derivatives/mpr_fs_reconall_$FSVERSION}"
                    OUTDIR="$(dirname $OUTDIR)/$(basename -s .nii.gz $OUTDIR)"

                    if [ ! -d $OUTDIR ] ; then
                        mkdir -p $OUTDIR
                    fi

                    echo "$OUTDIR $fn $SUBJID $FSVERSION"
                    qsub $BASE/jobFreesurferReconAll.sh $OUTDIR $fn $SUBJID $FSVERSION
                fi
            fi
        done # end for fn in session/anat/*.nii.gz
    done # end for session in subject
done # end for subject
