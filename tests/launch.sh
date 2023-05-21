#!/bin/bash

TESTS_PATH=`dirname $0`
REQV=${TESTS_PATH}/../bin/reqv

#basic test 1 upstream doc and 1 downstream doc
${REQV} -p ${TESTS_PATH}/inputs/01_basic_1.SSS_1.SRS/project.yaml -a "gen_traca  SSS<->SRS" -o ${TESTS_PATH}/outputs/01_basic_1.SSS_1.SRS

