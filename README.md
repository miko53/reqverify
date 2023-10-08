
# requiremement verify - reqv

This tool is a help to create, verify traceability matrix.

In some project, especially the critical one, it is necessary to build some documentation.
This document must demonstration that the software is correctly declined from upper specficiations.

This tool help to do the traceability.

You given your upper document (directly in yaml format or imported from excel or docx format) and it 
will calculate if all your requirements are correctly declined.

Here we are a example to better understand.

Taken as hypothesis that your system team builds a document which describes the system and software behavior.
Call this document (SSS for System/Subsystem Specification).

You must produce a document declined from it as basis for software development, call this document SRS (Software 
Requirement Specification)

For each requirement that your write into your SRS you must ensure that it is relies to SSS requirement.

![SSS_SRS](doc/SSS_SRS_link.png)


## How tool works ?

This tool works on intermediate data extracted for document. For example, documents are written with Excel or Word.

The tool will extract the requirement according to given rules and build a internal model on this.

Then you can request an export of the data, on the console to check in real time (when you write document) or
to generate the traceability matrix

Here we are a schema with involved files.

![req-verify-process](doc/reqverify-ex1.png)


## Example

The *Tests* folder contains a lot of examples. 
Let's examine a common use case, this one is stores in *example* folder

### begin by create project

../bin/reqvp help

../bin/reqvp create_project example_project req_project req_project.reqprj

### insert files
../bin/reqvp add_doc req_project/req_project.reqprj import SSS handler DocxImport SSS_sample.docx

../bin/reqvp add_plugin_rule req_project/req_project.reqprj SRS req_id_style_name REQ_ID
../bin/reqvp add_plugin_rule req_project/req_project.reqprj SRS req_title_style_name REQ_TITLE
../bin/reqvp add_plugin_rule req_project/req_project.reqprj SRS req_text_style_name REQ_TEXT
../bin/reqvp add_plugin_rule req_project/req_project.reqprj SRS req_cov_style_name REQ_COV
../bin/reqvp add_plugin_rule req_project/req_project.reqprj SRS req_attributes_style_name REQ_ATTRIBUTES

### insert rules

 ../bin/reqvp add_plugin_rule req_project/req_project.reqprj SSS req_id_style_name REQ_ID
 ../bin/reqvp add_plugin_rule req_project/req_project.reqprj SSS req_title_style_name REQ_TITLE
 ../bin/reqvp add_plugin_rule req_project/req_project.reqprj SSS req_text_style_name REQ_TEXT
 ../bin/reqvp add_plugin_rule req_project/req_project.reqprj SSS req_cov_style_name REQ_COV
 ../bin/reqvp add_plugin_rule req_project/req_project.reqprj SSS req_attributes_style_name REQ_ATTRIBUTES

### derived rules

../bin/reqvp add_derived_name req_project/req_project.reqprj "Derived"

### create relationship
../bin/reqvp add_relationships req_project/req_project.reqprj "SSS->SRS" SRS covered-by SSS


### build requirement list
../bin/reqv --project=req_project/req_project.yaml --action=status --relationship="SSS->SRS"
document: SRS
  coverage: 100%
  number of requirement: 10
  number of uncovered requirement: 0
  derived requirement: 20%
    SRS_004.1
    SRS_008.1
document: SSS
  coverage: 100%
  number of requirement: 10
  number of uncovered requirement: 0

### export requirement list
../bin/reqv --project=req_project/req_project.yaml --action=export --relationship="SSS->SRS" --format=xlsx --output-folder=. --output-file=traceability.xlsx

## TODO

- [ ] Add complete example with doc import
- [ ] Add delete part in reqvp executable
- [ ] create a GUI to explore requirement traceability
- [ ] add customization of output data
- [ ] create test in ruby format (no bash)
