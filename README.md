# Orion
A Big Data Interface of Tianhe-2
Orion is implemented via bash programming. And it employs the scheduling system of Tianhe-2 to allocate required computing resources and it utilizes the parallel filesystem of Tianhe-2 directly. 

In summary, Orion has the following features:

①It supports Hadoop and Spark configuration automatically, the user only needs to specify the framework type and the number of nodes.

②We use the original scheduling system of Tianhe-2 and do not use YARN for node management. 

③We use the H2FS filesystem of Tianhe-2 instead of HDFS. 

④We not only configure the framework work environment, but also enable related environments like NoSQL databases support (Redis, Mongo DB), OpenMP and MPI. 

⑤The Tianhe-2 monitoring subsystem can track the status of the created big data analytics platform dynamically. 

⑥The created data analytics platform can be created and retracted anytime as the users wish, so that users won’t be charged if their applications are not actually running.

 

------Instructions--------------------------------------------------------------------------------------------------------------

1.The installation directory

/ WORK / app / share / Orion

2.The initial situation in this directory is:

Orion_start.sh which is used for cluster configuration and start. Orion_clean.sh is in the task after the completion of the calculation or the release of resources when an error, clean up the directory. Script directory is used to store task scripts.

Hadoop running configuration

①Switch to the installation directory

②Configure and start a Hadoop cluster

To execute the wordcount.sh script directory, for example, the command is:

./Orion_start.sh -t hadoop -p work -N 6 -s 'pwd' / script / wordcount.sh

Where -t is the cluster type (Hadoop or spark), 

-p is the partition on which the cluster is running, 

-N is the number of nodes used, 

-s is the script of the task to run.

After the task is submitted, it will automatically queue up, wait for resources, if you can not wait for resources, the program will determine the exit, and prompts the replacement partition and adjust the number of nodes.
![image](https://github.com/yangxi1016/picture/raw/master/orion-readme1.png )

Once the resource is acquired, the Hadoop cluster is automatically configured and started, and the specified task script is executed.
![image](https://github.com/yangxi1016/picture/raw/master/orion-readme2.png )

Next, the output of the execution task script is output.
After the implementation is complete, the following prompts are given:
![image](https://github.com/yangxi1016/picture/raw/master/orion-readme3.png )

3.When processing is complete, release resources
![image](https://github.com/yangxi1016/picture/raw/master/orion-readme4.png )

4.About the task script

In the script directory is given an example wordcount.sh
 

Where $ {HADOOP_HOME} is the directory where Hadoop is installed. In general, modify the contents of the command can be. You can also specify a different output directory.

5.About the configuration file changes
![image](https://github.com/yangxi1016/picture/raw/master/orion-readme5.png )

If you want to modify the configuration file, you can switch to the installation directory under the magpie / conf directory, modify the corresponding file, modify and then take effect when you create a new cluster. You can also manually log in to the master node of the existing cluster and restart YARN and JobHistoryServer as described above.
![image](https://github.com/yangxi1016/picture/raw/master/orion-readme6.png )

For Hadoop, generally only need to modify the black display of several XML files. Note that all of these are based on the Lustre file system as a Hadoop, without the use of hdfs. Since Lustre is already globally shared, it is not necessary to introduce hdfs.
