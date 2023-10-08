#!/bin/bash

REQV=../bin/reqv
REQVP=../bin/reqvp

${REQVP} create_project example_project req_project req_project.reqprj

${REQVP} add_doc req_project/req_project.reqprj import SSS handler DocxImport SSS_sample.docx
${REQVP} add_doc req_project/req_project.reqprj import SRS handler DocxImport SRS_sample.docx

${REQVP} add_plugin_rule req_project/req_project.reqprj SRS req_id_style_name REQ_ID
${REQVP} add_plugin_rule req_project/req_project.reqprj SRS req_title_style_name REQ_TITLE
${REQVP} add_plugin_rule req_project/req_project.reqprj SRS req_text_style_name REQ_TEXT
${REQVP} add_plugin_rule req_project/req_project.reqprj SRS req_cov_style_name REQ_COV
${REQVP} add_plugin_rule req_project/req_project.reqprj SRS req_attributes_style_name REQ_ATTRIBUTES

${REQVP} add_plugin_rule req_project/req_project.reqprj SSS req_id_style_name REQ_ID
${REQVP} add_plugin_rule req_project/req_project.reqprj SSS req_title_style_name REQ_TITLE
${REQVP} add_plugin_rule req_project/req_project.reqprj SSS req_text_style_name REQ_TEXT
${REQVP} add_plugin_rule req_project/req_project.reqprj SSS req_cov_style_name REQ_COV
${REQVP} add_plugin_rule req_project/req_project.reqprj SSS req_attributes_style_name REQ_ATTRIBUTES

${REQVP} add_derived_name req_project/req_project.reqprj "Derived"

${REQVP} add_relationships req_project/req_project.reqprj "SSS->SRS" SRS covered-by SSS

${REQV} --project=req_project/req_project.reqprj --action=status --relationship="SSS->SRS"
