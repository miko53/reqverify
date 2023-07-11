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

#set -x

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
  derived requirement: 40%
    SRS_REQ_003.1
    SRS_REQ_005.1
document: SSS
  coverage: 75%
  number of requirement: 4
  number of uncovered requirement: 1
    SSS_REQ_002.1
END
)

#echo "$r"
check_string_result "$r" "${EXPECTED_OUTPUT}" "${TEST_NAME}"

#basic test 1 upstream doc and 1 downstream doc output xlsx
TEST_NAME="basic test - output xlsx"
${REQV} -p ${TESTS_PATH}/inputs/01_basic_1.SSS_1.SRS/project.yaml -a export -F xlsx -r "SSS<->SRS" -o ${TESTS_PATH}/outputs/03_basic_1.SSS_1.SRS -f 03.xlsx -v
check_file_exists "${TESTS_PATH}/outputs/03_basic_1.SSS_1.SRS/03.xlsx" "${TEST_NAME}"

#nominal 1 downstream, 2 upstream
TEST_NAME="nominal 1 downstream, 2 upstream"
${REQV} -p ${TESTS_PATH}/inputs/04_nominal_2.SSS_1.SRS/project.yaml -a export -F csv -r "SSS_all<->SRS" -o ${TESTS_PATH}/outputs/04_nominal_2.SSS_1.SRS -v
${DIFF} -r ${TESTS_PATH}/outputs/04_nominal_2.SSS_1.SRS ${TESTS_PATH}/expected/04_nominal_2.SSS_1.SRS
check_result $? "${TEST_NAME}"

#nominal 2 downstream, 1 upstream
TEST_NAME="nominal 2 downstream, 1 upstream"
${REQV} -p ${TESTS_PATH}/inputs/05_nominal_1.SRS_2.STD/project.yaml -a export -F csv -r "SRS<->STD_all" -o ${TESTS_PATH}/outputs/05_nominal_1.SRS_2.STD -v
${DIFF} -r ${TESTS_PATH}/outputs/05_nominal_1.SRS_2.STD ${TESTS_PATH}/expected/05_nominal_1.SRS_2.STD
check_result $? "${TEST_NAME}"

TEST_NAME="not found requirement 1 - check status ouput"
# sed command => to remove the color
# TODO put in file in expected folder
r=`${REQV} -p ${TESTS_PATH}/inputs/06_not_found_1.SSS_1.SRS/project.yaml -a status -r "SSS<->SRS" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g"`
EXPECTED_OUTPUT=$(cat <<-END
warning: 'SSS_REQ_010.1' doesn't exist !
warning: 'SSS_RSQ_003.1' doesn't exist !
document: SRS
  coverage: 80%
  number of requirement: 5
  number of uncovered requirement: 1
    SRS_REQ_001.1
  derived requirement: 40%
    SRS_REQ_003.1
    SRS_REQ_005.1
document: SSS
  coverage: 75%
  number of requirement: 4
  number of uncovered requirement: 1
    SSS_REQ_003.1
END
)
check_string_result "$r" "${EXPECTED_OUTPUT}" "${TEST_NAME}"

TEST_NAME="not found requirement 2 - check status ouput"
# sed command => to remove the color
# TODO put in file in expected folder
r=`${REQV} -p ${TESTS_PATH}/inputs/07_not_found_1.SRS_2.STD/project.yaml -a status -r "SRS<->STD_all" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g"`
EXPECTED_OUTPUT=$(cat <<-END
warning: 'SRS_REQ_010.1' doesn't exist !
warning: 'SRS_REQ_020.1' doesn't exist !
warning: 'SRS_REQ_101.1' doesn't exist !
warning: 'SRT_REQ_002.1' doesn't exist !
warning: 'SRS_REQ_03.1' doesn't exist !
warning: 'SRS_REQ_02.1' doesn't exist !
document: STD_1
  coverage: 40%
  number of requirement: 5
  number of uncovered requirement: 3
    STD_1_REQ_001.1
    STD_1_REQ_002.1
    STD_1_REQ_005.1
  derived requirement: 0%
document: STD_2
  coverage: 100%
  number of requirement: 6
  number of uncovered requirement: 0
  derived requirement: 0%
document: SRS
  coverage: 100%
  number of requirement: 6
  number of uncovered requirement: 0
END
)
check_string_result "$r" "${EXPECTED_OUTPUT}" "${TEST_NAME}"


# ../bin/reqv -p ./inputs/04_nominal_2.SSS_1.SRS/project.yaml -a status -r "SSS_all<->SRS" -d
# ../bin/reqv -p ./inputs/05_nominal_1.SRS_2.STD/project.yaml -a status -r "SRS<->STD_all" -d

