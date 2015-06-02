#!/bin/bash
hdfs namenode -format
start-all.sh
hdfs dfsadmin -report
