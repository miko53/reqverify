#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m' # No Color


TESTS_PATH=`dirname $0`
REQV=${TESTS_PATH}/../bin/reqv
DIFF=diff

# $1 result, $2 test name
check_result()
{
    ret=$?
    if [[ $1 -eq 0 ]]; then
        echo -e "${GREEN}TEST_RESULT: '$2' passed.${NO_COLOR}"
    else
        echo -e "${RED}TEST_RESULT: '$2' failed.${NO_COLOR}"
    fi    
}

# $1 string1, $2 string2, $3 test name
check_string_result()
{
    if [[ $1 == $2 ]]; then
        echo -e "${GREEN}TEST_RESULT: '$3' passed.${NO_COLOR}"
    else
        echo -e "${RED}TEST_RESULT: '$3' failed.${NO_COLOR}"
    fi
}

# $1 file to check, $2 test name
check_file_exists()
{
    if [ -f "$1" ]; then
        echo -e "${GREEN}TEST_RESULT: '$2' passed. -- check manually coherency -- ${NO_COLOR}"
    else
        echo -e "${RED}TEST_RESULT: '$2' failed.${NO_COLOR}"
    fi
}

# remove all previous data
rm -rf ${TESTS_PATH}/outputs/*

#basic test 1 upstream doc and 1 downstream doc
TEST_NAME="basic test - output csv"
${REQV} -p ${TESTS_PATH}/inputs/01_basic_1.SSS_1.SRS/project.yaml -a export -F csv -r "SSS<->SRS" -o ${TESTS_PATH}/outputs/01_basic_1.SSS_1.SRS  -v
${DIFF} -r ${TESTS_PATH}/outputs/01_basic_1.SSS_1.SRS ${TESTS_PATH}/expected/01_basic_1.SSS_1.SRS 
check_result $? "${TEST_NAME}"

TEST_NAME="basic test - missing requirement"
${REQV} -p ${TESTS_PATH}/inputs/02_basic_missing_req_1.SSS_1.SRS/project.yaml -a export -F csv -r "SSS<->SRS" -o ${TESTS_PATH}/outputs/02_basic_missing_req_1.SSS_1.SRS  -v
${DIFF} -r ${TESTS_PATH}/outputs/02_basic_missing_req_1.SSS_1.SRS ${TESTS_PATH}/expected/02_basic_missing_req_1.SSS_1.SRS 
check_result $? "${TEST_NAME}"

TEST_NAME="basic test - missing requirement - check status output"
# sed command => to remove the color
# TODO put in file in expected folder
r=`${REQV} -p ${TESTS_PATH}/inputs/02_basic_missing_req_1.SSS_1.SRS/project.yaml -a status -r "SSS<->SRS" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g"`
EXPECTED_OUTPUT=$(cat <<-END
document: SRS
  coverage: 60%
  number of requirement: 5
  number of uncovered requirement: 2
    SRS_REQ_001.1
    SRS_REQ_002.1
  derived requirement: 20%
document: SSS
  coverage: 75%
  number of requirement: 4
  number of uncovered requirement: 1
    SSS_REQ_002.1
END
)

#echo "$r"
check_string_result "$r" "${EXPECTED_OUTPUT}" "${TEST_NAME}"

#basic test 1 upstream doc and 1 downstream doc
TEST_NAME="basic test - output xlsx"
${REQV} -p ${TESTS_PATH}/inputs/01_basic_1.SSS_1.SRS/project.yaml -a export -F xlsx -r "SSS<->SRS" -o ${TESTS_PATH}/outputs/03_basic_1.SSS_1.SRS -f 03.xlsx -v
check_file_exists "${TESTS_PATH}/outputs/03_basic_1.SSS_1.SRS/03.xlsx" "${TEST_NAME}"
