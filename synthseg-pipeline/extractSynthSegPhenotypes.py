import os
import glob
import pandas as pd
import argparse

def parseSynthSegVolumes(ssFn):
    # load the subject's /synthseg_output/volumes.csv
    ssDf = pd.read_csv(ssFn)
     
    ssDf['TCV'] = ssDf['total intracranial']
    ssDf['Cortex'] = ssDf['left cerebral cortex'] + ssDf['right cerebral cortex'] 
    ssDf['WMV'] = ssDf['left cerebral white matter'] + ssDf['right cerebral white matter']
    ssDf['sGMV'] = ssDf['left thalamus'] + ssDf['left caudate'] + ssDf['left putamen'] + ssDf['left pallidum'] + ssDf['left hippocampus'] + ssDf['left amygdala'] + ssDf['left accumbens area'] + ssDf['right thalamus'] + ssDf['right caudate'] + ssDf['right putamen'] + ssDf['right pallidum'] + ssDf['right hippocampus'] + ssDf['right amygdala'] + ssDf['right accumbens area']
#    ssDf['brainStem'] = ssDf['brain-stem']
    ssDf['Ventricles'] = ssDf['left lateral ventricle'] + ssDf['right lateral ventricle'] + ssDf['left inferior lateral ventricle'] + ssDf['right inferior lateral ventricle'] + ssDf['3rd ventricle'] + ssDf['4th ventricle'] 
    ssDf['CerebellumVolume'] = ssDf['left cerebellum cortex'] + ssDf['left cerebellum white matter'] + ssDf['right cerebellum cortex'] + ssDf['right cerebellum white matter']

    return ssDf


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--directory', help='Path to the directory containing the outputs of the SynthSeg 2.0 jobs')
    parser.add_argument('-o', '--out-fn', help='Name of output file')

    args = parser.parse_args()
    print(args)

    path = args.directory
    outFn = args.out_fn

    fsVersion = "SynthSeg_2.0"
    useFirstRunOnly = True
    phenoDfList = []

    for subj in sorted(os.listdir(path)):
        if "sub-" in subj:
            subjDir = os.path.join(path, subj)
            for sess in sorted(os.listdir(subjDir)):
                sessDir = os.path.join(subjDir, sess)
                # Pull out the age
                ageDays = int(sess.split("age")[-1])
                # Get the list of volume output files
                volFns = sorted(glob.glob(os.path.join(sessDir, "**/volumes.csv"), recursive=True))
                print(subj, sess, ageDays, len(volFns))
                
                if useFirstRunOnly:
                    if type(volFns) is str:
                        volFns = [volFns]
                    else:
                        volFns = [volFns[0]]
                for volFn in volFns:
                    tmpDf = parseSynthSegVolumes(volFn)
                    tmpDf['subj_id'] = subj
                    tmpDf['sess_id'] = sess
                    tmpDf['scan_id'] = os.path.dirname(volFn)
                    tmpDf['fs_version'] = fsVersion
                    tmpDf['age_in_days'] = ageDays
                    # Rearrange columns
                    cols = list(tmpDf)
                    cols = cols[-5:] + cols[:-5]
                    tmpDf = tmpDf[cols]
                    # Add the dataframe for a single scan to the list of dataframes
                    phenoDfList.append(tmpDf)
    
    groupDf = pd.concat(phenoDfList, ignore_index=True)
    groupDf.to_csv(outFn, index=False)


if __name__ == "__main__":
    main()
