#!/bin/bash
i=1
#GRIDPACK=${!i}; i=$((i+1))
FRAGMENT=${!i}; i=$((i+1))
NEVENTS=${!i}; i=$((i+1))
NTHREADS=${!i}; i=$((i+1))
OUTPATH=${!i}; i=$((i+1))
PROC=${!i}; i=$((i+1))


#!/bin/bash
export HOME=`pwd`
git config --global user.name 'Samuel Webb'
git config --global user.email 'samuel.webb@cern.ch'
git config --global user.github snwebb

# export SCRAM_ARCH=slc6_amd64_gcc630
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_11_0_2/src ] ; then 
 echo release CMSSW_11_0_2 already exists
 cd CMSSW_11_0_2/src
 eval `scramv1 runtime -sh`
else
 scramv1 project CMSSW CMSSW_11_0_2
 cd CMSSW_11_0_2/src
 eval `scramv1 runtime -sh`
 git cms-init
 git cms-merge-topic kdlong:NanoGen_11_0_2
 scram b -j 5
#scram p CMSSW CMSSW_11_0_2
fi
#cd ~/work/private/Hinv/htcondormc/CMSSW_11_0_2/src
#eval `scram runtime -sh`

mkdir -p Configuration/GenProduction/python/
cp ${FRAGMENT}  Configuration/GenProduction/python/
#sed -i "s/@GRIDPACK/${GRIDPACK}" Configuration/GenProduction/python/$(basename $FRAGMENT)

[ -s Configuration/GenProduction/python/$(basename $FRAGMENT) ] || exit $?;

scram b
cd ../../
#seed=$(date +%s)+$PROC
#seed=$(( 1000000*$(date +%s)+$PROC ))
#seed=$(( 1000000*$(date +%s)+$PROC ))

seed=$(( $PROC + 1 ))
cmsDriver.py Configuration/GenProduction/python/$(basename $FRAGMENT) \
--fileout file:fxfxstudy.root \
--mc \
--eventcontent NANOAODSIM \
--datatier NANOAOD \
--conditions auto:mc \
--step LHE,GEN,NANOGEN \
--nThreads ${NTHREADS} \
--geometry DB:Extended \
--era Run2_2017 \
--python_filename fxfxstudy.py \
--no_exec \
--customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${seed})" \
-n ${NEVENTS} || exit $? ; 

#--customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${seed}%100)" \
#--customise Configuration/DataProcessing/Utils.addMonitoring \

cmsRun fxfxstudy.py | tee log_fxfxstudy.txt

OUTTAG=$(echo $JOBFEATURES | sed "s|_[0-9]*$||;s|.*_||")

if [ -z "${OUTTAG}" ]; then
    OUTTAG=$(md5sum *.root | head -1 | awk '{print $1}')
fi

echo "Using output tag: ${OUTTAG}"
mkdir -p ${OUTPATH}
for file in *.root; do 
    mv $file $OUTPATH/$(echo $file | sed "s|.root|_${OUTTAG}.root|g")
done
for file in *.txt; do 
    mv $file $OUTPATH/$(echo $file | sed "s|.root|_${OUTTAG}.txt|g")
done
