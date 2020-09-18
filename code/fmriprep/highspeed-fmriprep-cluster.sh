#!/usr/bin/bash
# ==============================================================================
# SCRIPT INFORMATION:
# ==============================================================================
# SCRIPT: RUN FMRIPREP ON THE MPIB CLUSTER (TARDIS)
# PROJECT: HIGHSPEED
# WRITTEN BY LENNART WITTKUHN, 2018 - 2020
# CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
# MAX PLANCK RESEARCH GROUP NEUROCODE
# MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT
# MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
# LENTZEALLEE 94, 14195 BERLIN, GERMANY
# ACKNOWLEDGEMENTS: THANKS HRVOJE STOJIC (UCL) AND ALEX SKOWRON (MPIB) FOR HELP
# ==============================================================================
# DEFINE ALL PATHS:
# ==============================================================================
# path to the base directory:
PATH_BASE="${HOME}"
# path to the project root directory
PATH_ROOT="${PATH_BASE}/highspeed"
# define the name of the project:
PROJECT_NAME="highspeed-fmriprep"
# define the path to the project folder:
PATH_PROJECT="${PATH_ROOT}/${PROJECT_NAME}"
# define the name of the current task:
TASK_NAME="fmriprep"
# path to the current shell script:
PATH_CODE=${PATH_PROJECT}/code
# cd into the directory of the current script:
cd "${PATH_CODE}/${TASK_NAME}"
# path to the fmriprep ressources folder:
PATH_FMRIPREP=${PATH_PROJECT}/tools/${TASK_NAME}
# path to the fmriprep singularity image:
PATH_CONTAINER=${PATH_FMRIPREP}/${TASK_NAME}_1.2.2.sif
# path to the freesurfer license file on tardis:
PATH_FS_LICENSE=${PATH_FMRIPREP}/fs_600_license.txt
# path to the data directory (in bids format):
PATH_BIDS=${PATH_PROJECT}//bids
# path to the output directory:
PATH_OUT=${PATH_PROJECT}
# path to the freesurfer output directory:
PATH_FREESURFER="${PATH_OUT}/freesurfer"
# path to the working directory:
PATH_WORK=${PATH_PROJECT}/work
# path to the log directory:
PATH_LOG=${PATH_PROJECT}/logs/$(date '+%Y%m%d_%H%M%S')
# path to the text file with all subject ids:
PATH_SUB_LIST="${PATH_CODE}/fmriprep/highspeed-participant-list.txt"
# ==============================================================================
# CREATE RELEVANT DIRECTORIES:
# ==============================================================================
# create output directory:
if [ ! -d ${PATH_OUT} ]; then
	mkdir -p ${PATH_OUT}
fi
# create freesurfer output directory
if [ ! -d ${PATH_FREESURFER} ]; then
	mkdir -p ${PATH_FREESURFER}
fi
# create directory for work:
if [ ! -d ${PATH_WORK} ]; then
	mkdir -p ${PATH_WORK}
fi
# create directory for log files:
if [ ! -d ${PATH_LOG} ]; then
	mkdir -p ${PATH_LOG}
fi
# ==============================================================================
# DEFINE PARAMETERS:
# ==============================================================================
# maximum number of cpus per process:
N_CPUS=8
# maximum number of threads per process:
N_THREADS=8
# memory demand in *GB*
MEM_GB=35
# memory demand in *MB*
MEM_MB="$((${MEM_GB} * 1000))"
# user-defined subject list
PARTICIPANTS=$1
# check if user input was supplied:
if [ -z "$PARTICIPANTS" ]; then
    echo "No participant label supplied."
    # read subject ids from the list of the text file	
    	SUB_LIST=$(cat ${PATH_SUB_LIST} | tr '\n' ' ')
else
	SUB_LIST=$PARTICIPANTS
fi
# ==============================================================================
# RUN FMRIPREP:
# ==============================================================================
# initalize a subject counter:
SUB_COUNT=0
# loop over all subjects:
for SUB in ${SUB_LIST}; do
	# update the subject counter:
	let SUB_COUNT=SUB_COUNT+1
	# get the subject number with zero padding:
	SUB_PAD=$(printf "%02d\n" $SUB_COUNT)
	# create participant-specific working directory:
	PATH_WORK_SUB="${PATH_WORK}/sub-${SUB_PAD}"
	if [ ! -d ${PATH_WORK_SUB} ]; then
		mkdir -p ${PATH_WORK_SUB}
	fi
	# create a new job file:
	echo "#!/bin/bash" > job
	# name of the job
	echo "#SBATCH --job-name fmriprep_sub-${SUB_PAD}" >> job
	# add partition to job
	echo "#SBATCH --partition gpu" >> job
	# set the expected maximum running time for the job:
	echo "#SBATCH --time 40:00:00" >> job
	# determine how much RAM your operation needs:
	echo "#SBATCH --mem ${MEM_GB}GB" >> job
	# email notification on abort/end, use 'n' for no notification:
	echo "#SBATCH --mail-type NONE" >> job
	# write log to log folder
	echo "#SBATCH --output ${PATH_LOG}/slurm-fmriprep-%j.out" >> job
	# request multiple cpus
	echo "#SBATCH --cpus-per-task ${N_CPUS}" >> job
	# define the fmriprep command:
	echo "singularity run --cleanenv -B ${PATH_BIDS}:/input:ro \
	-B ${PATH_OUT}:/output:rw -B ${PATH_FMRIPREP}:/utilities:ro \
	-B ${PATH_FREESURFER}:/output/freesurfer:rw \
	-B ${PATH_WORK_SUB}:/work:rw ${PATH_CONTAINER} \
	--fs-license-file /utilities/fs_600_license.txt \
	/input/ /output/ participant --participant_label ${SUB_PAD} -w /work/ \
	--mem_mb ${MEM_MB} --nthreads ${N_CPUS} --omp-nthreads $N_THREADS \
	--write-graph --stop-on-first-crash \
	--output-space T1w fsnative template fsaverage \
	--notrack --verbose --resource-monitor" >> job
	# submit job to cluster queue and remove it to avoid confusion:
	sbatch job
	rm -f job
done
