### 

This folder contains scripts for running `recon-all` using FreeSurfer or Infant FreeSurfer. 

### Software Requirements

- FreeSurfer 5.3.0/6.0.0/7.1.1
- Infant FreeSurfer (2021-01-12 update)

FreeSurfer 5.3.0 and 6.0.0 are installed as modules on CUBIC as of 2021-10-22. FreeSurfer 7.1.1 must be installed separately and loaded using a bit of bash/module management trickery.


The code for Infant FreeSurfer can be requested [here](https://surfer.nmr.mgh.harvard.edu/fswiki/infantFS). There is something related to FSL licenses that could make install via Docker tricky.


### Structural Requirements


The job submission script assumes not only that the data is organized in BIDS directory format, but also that the session identifier ends with age information. Specifically, the session identifier must end with "ageXXXXX" where XXXXX is a zero padded five digit string specifying the patients age at the time of the scan in days. 

Example:

```
dataset/
├─ derivatives/
├─ sourcedata/
│  ├─ subject-001/
|  |  ├─ ScanSession01PatientAge727/
|  |  ├─ ScanSession02PatientAge5063/
│  ├─ subject-002/
│  ├─ subject-003/
├─ rawdata/
│  ├─ sub-S001/
|  |  ├─ ses-01age00727/
|  |  |  ├─ anat/
|  |  |  |  ├─ sub-S001_ses-01age00727_acq-MPR_run-01_T1w.nii.gz
|  |  |  |  ├─ sub-S001_ses-01age00727_acq-MPR_run-01_T1w.json
|  |  ├─ ses-02age05063/
│  ├─ sub-S002/

```

In the `sourcedata` directory, there are three subjects: subject-001, subject-002, and subject-003. When we look at the contents of the `subject-001` folder, we see two folders labeled as scan sessions: ScanSession01PatientAge727 and ScanSession02PatientAge5063. This data is the original data and should be retained in its original form. The heudiconv and CuBIDs tools can be used to generate a version of the data in a parallel directory where the files are in .nii.gz/.json format and the directory structure follows the BIDS format.


The output of the heudiconv and CuBIDS process lives in the `rawdata` directory. The top level of this directory is the subject level. Every folder in this level must follow the naming convention of "sub-" followed by a unique subject identifier. Within a subject's directory live its session directories. The session directory names follow a similar convention of "ses-" combined with a unique session identifier. For this pipeline, the session identifier must end with "ageXXXXX", where "XXXXX" is a five digit zero padded number indicating the patient age in days. 


*Why age in days is needed*: this pipeline runs Infant FreeSurfer's `infant_recon_all` on patients younger than 2 years (730.5 days), FreeSurfer's `recon-all` on patients older than 3 years (1095.25 days), and both `infant_recon_all` and `recon-all` for patients between 2 and 3 years old.


### Usage

Point the main script `mpr_job_submitter.sh` at a BIDS `rawdata` directory as described in the previous section and give it the numeric version of FreeSurfer to use.

`mpr_job_submitter.sh /path/to/bids/rawdata/ "7.1.1"`

Note: the `recon-all` job runs a preprocessing step on the images before starting recon-all. This step uses a script (preprocWashUACPCAlignment.sh) from Damien Fair's group at Washington University St. Louis to align the image to the MNI atlas and resample the image to have 1 mm voxels. Currently, no preprocessing is performed on the `infant_recon_all` jobs. 
