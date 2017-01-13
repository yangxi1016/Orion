#!/bin/bash
#
# Orion data analytics configuration and initialization

orion_no=`yhqueue | grep Orion | wc -l`
orion_no=`expr $orion_no + 1`

fw_type=''
fw_arg=''
t_flag=0
p_flag=0
n_flag=0
s_flag=0
target_shell=""

while getopts :t:p:N:s: x
do
    #echo $OPTARG
    case $x in
    	t) fw_type=$OPTARG; t_flag=1 ;;
        p) fw_arg=$fw_arg" -p $OPTARG"; p_flag=1 ;;
        N) fw_arg=$fw_arg" -N $OPTARG"; n_flag=1 ;;
        s) target_shell=$OPTARG; s_flag=1 ;;
        ?) echo "Invalid options!" ;;
    esac
done

if [ ${t_flag} -eq 0 ] || [ ${p_flag} -eq 0 ] || [ ${n_flag} -eq 0 ];
then
    echo "Please specify framework type, running partition and number of nodes to run"
    exit
fi

echo "Orion data analytics initialization..."

precmd="yhbatch --ntasks-per-node=1  --exclusive --no-kill -J Orion-$orion_no" 
cmd=$precmd
#echo "Allocating computing resources as demanded by:"
#alloc_cmd="yhalloc -J Orion-$orion_no --no-shell"
#cmd=$alloc_cmd$fw_arg

#echo $cmd
#$cmd

if [ "${fw_type}" == "hadoop" ];
then
    echo "Hadoop framework selected."

    poscmd=" magpie/submission-scripts/script-sbatch-srun/magpie.th-hadoop"
    cmd=$precmd$fw_arg$poscmd
    echo $cmd

    $cmd
    
    echo "Creating Hadoop cluster..." 


   while :
    do
        status=`yhqueue | grep Orion-$orion_no | awk -F ' ' '{print $5}'`
        jobid=`yhqueue | grep Orion-$orion_no | awk -F ' ' '{print $1}'`
        #echo $status

	echo "Waiting for resource allocation, queuing..."
        if [ "${status}" == "R" ];
        then
	    #node_list=`yhqueue | grep 'Orion' | awk -F' ' '{print $8}'`
	    echo "Requested resources allocated."
            break
        fi

        if [[ $scnt > 10 ]];
        then
	    echo "Cannot get the applied resources, please consider change the partition or reduce node demands. "
            exit
        fi

        sleep 5s
    done

    scnt=0

    echo "Executing cluster configuration..."
    echo "Hold on for a moment..."

    while [ ! -f "slurm-${jobid}.out" ]
    do
        sleep 5s
#	echo `yhqueue`
    done

    while :
    do
        log_msg=`grep "Entering Hadoop interactive mode" slurm-${jobid}.out`

        if [ "${log_msg}X" == "X" ];
        then
            sleep 10s
        else
            break
        fi
    done

    echo "Configuration done. Data processing cluster up and running."

    #Setting up environment variables. 
    RUN_ENVIRONMENT_VARIABLE_SCRIPT="/vol7/home/chengkun/Orion/${jobid}/orion-job-env"
    source $RUN_ENVIRONMENT_VARIABLE_SCRIPT

    #master_node=`yhqueue | grep Orion-$orion_no | awk -F ' ' '{print $8}' | tr '-' ' ' | tr -d '[cn\[\]]' | awk -F ' ' '{print "cn"$1}'`
    #echo $master_node

    if [ ${s_flag} -eq 0 ];
    then
        echo "*************************************"
        echo "Did not specify a job script, please submit a task as follows"
        echo "1. ssh ${HADOOP_MASTER_NODE}"
        echo "2. source ${RUN_ENVIRONMENT_VARIABLE_SCRIPT}"
        echo "3. cd ${HADOOP_HOME}/bin"
        echo "4. hadoop jar ..."
        echo "*************************************"
    else

        echo "Hadoop home directory: ${HADOOP_HOME}"
        echo "Hadoop local directory: ${HADOOP_LOCAL_DIR}@${HADOOP_MASTER_NODE}"
        echo "Hadoop config directory: ${HADOOP_CONF_DIR}@${HADOOP_MASTER_NODE}"

        remote_cmd="source ${RUN_ENVIRONMENT_VARIABLE_SCRIPT}; ${target_shell}"
        echo $remote_cmd
   
        echo "Now executing the script ${target_shell}"

        ssh ${HADOOP_MASTER_NODE} "${remote_cmd}"

        wait

        echo "Taks completed. Check the log."
        echo "The data processing cluster is still up, you can submit another task now."
        echo "*************************************"
        echo "1. ssh ${HADOOP_MASTER_NODE}"
        echo "2. source ${RUN_ENVIRONMENT_VARIABLE_SCRIPT}"
        echo "3. cd ${HADOOP_HOME}/bin"
        echo "4. hadoop jar ..."
        echo "*************************************"
        echo "To terminate the cluster and release the resources, please run:"
        #echo "yhcancel ${jobid}"
        echo "./Orion_clean.sh -j ${jobid}"
    fi
elif [ "${fw_type}" == "spark" ];
then
    echo "You have selected the Spark framework!"
else
    echo "Spark not yet installed."
fi


