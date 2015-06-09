#!/bin/bash
cat ../Small_Test/small_test/shop1 | map_input_file=shop1 ../mapper_s1 > shop1_s1_out
cat shop1_s1_out | ../reducer_s1 > shop1_s2_out


