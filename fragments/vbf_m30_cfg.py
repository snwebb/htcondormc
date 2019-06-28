import FWCore.ParameterSet.Config as cms


# link to datacards: 
# https://github.com/cms-sw/genproductions/tree/da9674a3507c727dfd7042001b989782859101d6/bin/MadGraph5_aMCatNLO/cards/production/2017/13TeV/Higgs/vbfh_5f_NLO_

externalLHEProducer = cms.EDProducer("ExternalLHEProducer",
    args = cms.vstring('/afs/cern.ch/work/a/aalbert/public/2019-06-07_lowmassdiphoton/htcondormc/gridpacks/vbfh_5f_NLO_30_slc6_amd64_gcc630_CMSSW_9_3_8_tarball.tar.xzz'),
    nEvents = cms.untracked.uint32(5000),
    numberOfParameters = cms.uint32(1),
    outputFile = cms.string('cmsgrid_final.lhe'),
    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh')
)

#Link to GS fragment
from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunes2017.PythiaCP5Settings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *
from Configuration.Generator.Pythia8aMCatNLOSettings_cfi import *

generator = cms.EDFilter("Pythia8HadronizerFilter",
	                     maxEventsToPrint = cms.untracked.int32(1),
                         pythiaPylistVerbosity = cms.untracked.int32(1),
                         filterEfficiency = cms.untracked.double(1.0),
                         pythiaHepMCVerbosity = cms.untracked.bool(False),
                         comEnergy = cms.double(13000.),
                         PythiaParameters = cms.PSet(
     pythia8CommonSettingsBlock,
     pythia8CP5SettingsBlock,
     pythia8PSweightsSettingsBlock,
     pythia8aMCatNLOSettingsBlock,
     processParameters = cms.vstring(
         'TimeShower:nPartonsInBorn = 2', #number of coloured particles (before resonance decays) in born matrix element
         'SLHA:useDecayTable = off',
         '25:m0 = 70.0',
         '25:onMode = off',
         '25:onIfMatch = 22 22',
         ),
     parameterSets = cms.vstring('pythia8CommonSettings',
                                 'pythia8CP5Settings',
                                 'pythia8PSweightsSettings',
                                 'pythia8aMCatNLOSettings',
                                 'processParameters',
                                 )
     )
)

ProductionFilterSequence = cms.Sequence(generator)
