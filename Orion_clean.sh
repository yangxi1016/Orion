#!/bin/sh
# This script will clean up a previously configured data processing cluster and release allocated resources. 

job_id=''
jflag=0

while getopts :j: x
do
	case $x in
		j) job_id=$OPTARG; jflag=1 ;;
		?) echo "Invalid options" ;;
	esac
done

if [ ${jflag} -eq 0 ] ;
then
    echo "Please specify the job id to cleanup" 
    exit
fi

echo "Cleaning up for job ${job_id}..."

status=`yhqueue | grep ${job_id} | awk -F ' ' '{print $5}'`
        
echo $status

if [ "${status}" == "R" ];
then
    export RUN_ENVIRONMENT_VARIABLE_SCRIPT="/vol7/home/chengkun/Orion/${job_id}/orion-job-env"
    source $RUN_ENVIRONMENT_VARIABLE_SCRIPT
    master_node=`yhqueue | grep Orion-$orion_no | awk -F ' ' '{print $8}' | tr '-' ' ' | tr -d '[cn\[\]]' | awk -F ' ' '{print "cn"$1}'`
    echo "Master node is " $master_node
    echo "Stopping Hadoop daemons"
    export SLURM_JOB_ID=${job_id}
    #yhrun -n 1 -w $master_node $HADOOP_HOME/sbin/stop-yarn.sh 
    yhrun -n 1 -w $master_node `echo ${HADOOP_HOME}`
    yhcancel ${job_id}
    wait
    echo "Nodes allocated to job ${job_id} are now released. "
fi

if [ -d "${job_id}" ];
then
	rm -rf ${job_id}
	wait 
	echo "Temporary directory removed."
fi

if [ -f "slurm-${job_id}.out" ];
then
	rm "slurm-${job_id}.out"
	wait 
	echo "Orion output removed. "
fi

echo "Cleanup done!"
