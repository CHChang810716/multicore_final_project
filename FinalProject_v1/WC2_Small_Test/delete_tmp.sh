#!/bin/bash
rm -rf /usr/local/hadoop/tmp
ssh slave1 'rm -rf /usr/local/hadoop/tmp'
ssh slave2 'rm -rf /usr/local/hadoop/tmp'
ssh slave3 'rm -rf /usr/local/hadoop/tmp'
