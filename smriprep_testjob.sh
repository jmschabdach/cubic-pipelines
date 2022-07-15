#!/bin/sh
#
# The name of the job
#$ -N smriprep-test-job
#
# Join stdout and stderrL:
#$ -j y

# singularity help # perl error in singularity, not smriprep

#export SINGULARITYENV_PREPEND_PATH=$PATH


# -v --fs-subjects-dir /cbica/projects/bgdimagecentral/Data/clip-controls/rawdata/ \

singularity exec --cleanenv \
--home /cbica/projects/bgdimagecentral \
/cbica/projects/bgdimagecentral/.containers/smriprep-0.8.2.simg \
smriprep --fs-license-file $HOME/.containers/fs_license.txt  \
 /cbica/projects/bgdimagecentral/Data/clip-controls/rawdata/ \
 /cbica/projects/bgdimagecentral/Data/clip-controls/derivatives/smriprep-0.8.2-test/ \
 participant --participant-label HM9BLERT0
