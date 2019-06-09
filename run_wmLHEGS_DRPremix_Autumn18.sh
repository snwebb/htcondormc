#!/bin/bash
i=1
FRAGMENT=${!i}; i=$((i+1))
NEVENTS=${!i}; i=$((i+1))
NTHREADS=${!i}; i=$((i+1))
OUTPATH=${!i}; i=$((i+1))

############################################
# ---------------- wmLHEGS-----------------
############################################
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_2_7/src ] ; then 
 echo release CMSSW_10_2_7 already exists
else
scram p CMSSW CMSSW_10_2_7
fi
cd CMSSW_10_2_7/src
eval `scram runtime -sh`

mkdir -p Configuration/GenProduction/python/
cp ${FRAGMENT}  Configuration/GenProduction/python/

[ -s Configuration/GenProduction/python/$(basename $FRAGMENT) ] || exit $?;

scram b
cd ../../
seed=$(date +%s)
cmsDriver.py Configuration/GenProduction/python/$(basename $FRAGMENT) \
--fileout file:wmLHEGS.root \
--mc \
--eventcontent RAWSIM,LHE \
--datatier GEN-SIM,LHE \
--conditions 102X_upgrade2018_realistic_v11 \
--beamspot Realistic25ns13TeVEarly2018Collision \
--step LHE,GEN,SIM \
--nThreads ${NTHREADS} \
--geometry DB:Extended \
--era Run2_2018 \
--python_filename wmLHEGS_cfg.py \
--no_exec \
--customise Configuration/DataProcessing/Utils.addMonitoring \
--customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${seed}%100)" \
-n ${NEVENTS} || exit $? ; 

cmsRun wmLHEGS_cfg.py | tee log_wmLHEGS.txt

############################################
# ---------------- DR-----------------
############################################
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_2_5/src ] ; then 
 echo release CMSSW_10_2_5 already exists
else
scram p CMSSW CMSSW_10_2_5
fi
cd CMSSW_10_2_5/src
eval `scram runtime -sh`



echo "Choose random PU input file."
PULIST=(`/cvmfs/cms.cern.ch/slc6_amd64_gcc700/cms/dasgoclient/v01.01.08/bin/dasgoclient --query='file dataset=/Neutrino_E-10_gun/RunIISummer17PrePremix-PUAutumn18_102X_upgrade2018_realistic_v15-v1/GEN-SIM-DIGI-RAW'`)
PUFILE=${PULIST[$RANDOM % ${#PULIST[@]}]}
echo "Chose PU File: ${PUFILE}"


scram b
cd ../../
cmsDriver.py step1 \
--filein file:wmLHEGS.root \
--fileout file:DRPremix_step1.root  \
--pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer17PrePremix-PUAutumn18_102X_upgrade2018_realistic_v15-v1/GEN-SIM-DIGI-RAW" \
--mc \
--eventcontent PREMIXRAW \
--datatier GEN-SIM-RAW \
--conditions 102X_upgrade2018_realistic_v15 \
--step DIGI,DATAMIX,L1,DIGI2RAW,HLT:@relval2018 \
--procModifiers premix_stage2 \
--nThreads ${NTHREADS} \
--geometry DB:Extended \
--datamix PreMix \
--era Run2_2018 \
--python_filename DRPremix_1_cfg.py \
--no_exec \
--customise Configuration/DataProcessing/Utils.addMonitoring \
-n ${NEVENTS} || exit $? ; 

cmsRun DRPremix_1_cfg.py | tee log_DRPremix_1.txt


cmsDriver.py step2 \
--filein file:DRPremix_step1.root \
--fileout file:DRPremix.root \
--mc \
--eventcontent AODSIM \
--runUnscheduled \
--datatier AODSIM \
--conditions 102X_upgrade2018_realistic_v15 \
--step RAW2DIGI,L1Reco,RECO,RECOSIM,EI \
--procModifiers premix_stage2 \
--nThreads ${NTHREADS} \
--era Run2_2018 \
--python_filename DRPremix_2_cfg.py \
--no_exec \
--customise Configuration/DataProcessing/Utils.addMonitoring -n ${NEVENTS} || exit $? ; 

cmsRun DRPremix_2_cfg | tee log_DRPremix_2.txt

mv DRPremix.root $OUTPATH

# ############################################
# # ---------------- MINIAOD-----------------
# ############################################

# cmsDriver.py step1 --filein "dbs:/GluGluHToGG_M70_TuneCP5_13TeV-amcatnloFXFX-pythia8/RunIIAutumn18DRPremix-102X_upgrade2018_realistic_v15-v1/AODSIM" --fileout file:HIG-RunIIAutumn18MiniAOD-01224.root --mc --eventcontent MINIAODSIM --runUnscheduled --datatier MINIAODSIM --conditions 102X_upgrade2018_realistic_v15 --step PAT --nThreads 8 --geometry DB:Extended --era Run2_2018 --python_filename HIG-RunIIAutumn18MiniAOD-01224_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 8597 || exit $? ; 

