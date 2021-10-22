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
                    echo 
                    OUTDIR="${fn/rawdata/derivatives/mpr_ifs_reconall_$FSVERSION}"
                    OUTDIR=${OUTDIR%%.nii.gz}
                    echo $OUTDIR

                    if [ ! -d $OUTDIR ] ; then
                        mkdir -p $OUTDIR
                    fi

                    ### start the infant freesurfer job
                    qsub $BASE/jobInfantFreesurferReconAll.sh $fn $OUTDIR $ageNum $FSVERSION
                # else if the age is less than 3 years
                elif [ $ageNum -lt 1096 ] ; then
                    ### start both an infant freesurfer job 
                    echo 
                    OUTDIR="${fn/rawdata/derivatives/mpr_ifs_reconall_$FSVERSION}"
                    OUTDIR=${OUTDIR%%.nii.gz}
                    echo $OUTDIR

                    if [ ! -d $OUTDIR ] ; then
                        mkdir -p $OUTDIR
                    fi

                    qsub $BASE/jobInfantFreesurferReconAll.sh $fn $ageNum $FSVERSION

                    ### start a regular freesurfer job 
                    echo 
                    OUTDIR="${fn/rawdata/derivatives/mpr_fs_reconall_$FSVERSION}"
                    OUTDIR=${OUTDIR%%.nii.gz}
                    echo $OUTDIR

                    if [ ! -d $OUTDIR ] ; then
                        mkdir -p $OUTDIR
                    fi
                    echo $OUTDIR

                    qsub $BASE/jobFreesurferReconAll.sh $OUTDIR $fn $SUBJID $FSVERSION

                # else age > 3 years
                else 
                    ### start a regular freesurfer job 
                    echo 
                    OUTDIR="${fn/rawdata/derivatives/mpr_fs_reconall_$FSVERSION}"
                    echo $OUTDIR
                    OUTDIR=${OUTDIR%%.nii.gz}
                    echo $OUTDIR
                    # OUTDIR="${fn/rawdata/derivatives/mpr_fs_reconall_$FSVERSION}$SUBJID/$(basename $session)/$(basename -s .nii.gz $fn)"
                    # echo $OUTDIR

                    if [ ! -d $OUTDIR ] ; then
                        mkdir -p $OUTDIR
                    fi

                    #echo "$OUTDIR $fn $SUBJID $FSVERSION"
                    qsub $BASE/jobFreesurferReconAll.sh $OUTDIR $fn $SUBJID $FSVERSION
                fi
            fi
        done # end for fn in session/anat/*.nii.gz
    done # end for session in subject
done # end for subject
