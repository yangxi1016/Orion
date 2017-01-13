#!/bin/sh

# This script just lists the files in your HDFS home dir.
#
# Convenient for just looking to see what's in there, perhaps after a job

cd ${HADOOP_HOME}

output_dir="/tmp/bigdata_out/"

if [ -d "$output_dir" ]; 
then
	rm -rf $output_dir
fi

command="bin/hadoop jar /vol7/home/chengkun/tools/hadoop-2.6.4/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.4.jar wordcount /vol7/home/chengkun/tools/hadoop-2.6.4/README.txt ${output_dir}"

echo "Running $command" >&2
$command

exit 0
