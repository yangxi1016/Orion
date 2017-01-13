# Orion1
A Big Data Analytics Platform of Tianhe-2
Orion is implemented via bash programming. And it employs the scheduling system of Tianhe-2 to allocate required computing resources and it utilizes the parallel filesystem of Tianhe-2 directly. 

In summary, Orion has the following features:
It supports Hadoop and Spark configuration automatically, the user only needs to specify the framework type and the number of nodes.
We use the original scheduling system of Tianhe-2 and do not use YARN for node management. 
We use the H2FS filesystem of Tianhe-2 instead of HDFS. 
We not only configure the framework work environment, but also enable related environments like NoSQL databases support (Redis, Mongo DB), OpenMP and MPI. 
The Tianhe-2 monitoring subsystem can track the status of the created big data analytics platform dynamically. 
The created data analytics platform can be created and retracted anytime as the users wish, so that users won’t be charged if their applications are not actually running.