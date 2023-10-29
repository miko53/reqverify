
# Requiremement verify tool - reqv

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
Let's examine a common use case, this one is stored in *example* folder. It can be built from `example` folder

We have two documents in docx, a system specification (SSS) and a software specification (SRS), and we have a 
traceability between SSS and SRS.

Then starts by create a project.

> [!NOTE]
> reqverify is in fact two tools, `reqv` to check traceability and `reqvp` to manage project

### Create project

So create the project with `reqvp`

```
reqvp create_project example_project req_project req_project.reqprj
```

> [!NOTE]
> `reqvp` contains a help command to see list of possibility

```
reqvp help
reqvp commands:
reqvp create_project <project_name> <folder> <filename> create a new project in the given folder with the given filename
reqvp add_doc <project_file> raw <doc_name> <doc_filename>
reqvp add_doc <project_file> import <doc_name> handler <import_plugin> <doc_filename> <doc_yaml_file,optional>
reqvp add_plugin_rule <project_file> <doc_name> <rule_name> <rule_value> <rule_type, optional>
reqvp add_relationships <project_file> <relation name> <doc_list> covered-by <doc_list>
reqvp add_derived_name <project_file> <derived_regular exp>
```

### Insert files

Now we need insert file (document) and indicate how to manage it. Here we indicates that it is docx file
managed by DocxImport plugin.

```
reqvp add_doc req_project/req_project.reqprj import SSS handler DocxImport SSS_sample.docx
reqvp add_doc req_project/req_project.reqprj import SRS handler DocxImport SRS_sample.docx
```

### Insert rules

The DocxImport plugin is configurable, it retrieves requirement and their characterics by style. These styles must be indicates.

Each document can be configurable independantly and it is possible to use your own plugin.

```
reqvp add_plugin_rule req_project/req_project.reqprj SRS req_id_style_name REQ_ID
reqvp add_plugin_rule req_project/req_project.reqprj SRS req_title_style_name REQ_TITLE
reqvp add_plugin_rule req_project/req_project.reqprj SRS req_text_style_name REQ_TEXT
reqvp add_plugin_rule req_project/req_project.reqprj SRS req_cov_style_name REQ_COV
reqvp add_plugin_rule req_project/req_project.reqprj SRS req_attributes_style_name REQ_ATTRIBUTES
```

```
reqvp add_plugin_rule req_project/req_project.reqprj SSS req_id_style_name REQ_ID
reqvp add_plugin_rule req_project/req_project.reqprj SSS req_title_style_name REQ_TITLE
reqvp add_plugin_rule req_project/req_project.reqprj SSS req_text_style_name REQ_TEXT
reqvp add_plugin_rule req_project/req_project.reqprj SSS req_cov_style_name REQ_COV
reqvp add_plugin_rule req_project/req_project.reqprj SSS req_attributes_style_name REQ_ATTRIBUTES
```

> [!NOTE]
> see plugin to have more information on how deal with them.

### Derived rules

To identify the derived requirement, the used rule in coverable must be given.

The following command does that:

```
reqvp add_derived_name req_project/req_project.reqprj "Derived"
```

### Create relationship

Now to finish, we must give the relationship between the document.
Here the SSS requirement must be covered by SRS.

```
reqvp add_relationships req_project/req_project.reqprj "SSS->SRS" SRS covered-by SSS
```

> [!NOTE]
> it is posssible to have more complex relationship (1->N N->1 etc.)


### Build requirement list

Now we can chech the traceabilty with the following command:

```
reqv --project=req_project/req_project.reqprj --action=status --relationship="SSS->SRS"
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
```

### Export requirement list

We can also export the result into a file, here an excel sheet:

```
reqv --project=req_project/req_project.reqprj --action=export --relationship="SSS->SRS" --format=XlsxExport --output-folder=. --output-file=traceability.xlsx
```

## Plugins (for importing or exporting)

Currently it exists two import plugins. For importing docx (or docm) document or important excel (xls) one.
See in `lib/plugins/` folder. 

These plugin use *docx* and *roo-xls* gems.

The base class is `Reqv::Import`. Each ones has a configuration part named *rules*.
These rules are read in the project file.

To see rules, see the function `set_rules` or each import plugins. Parameters given to function are directly taken from project file (`handler-rules:`)


### Build own plugin.

It is in fact the same format that the build-in ones, but you can save them into another folder.
See *tests/custom_plugins_dir* folder for a complete example.

## Exports

Currently two formats are managed, xlsx and csv. xlsx export uses *caxlsx* gems.
Configuration will by possible in the future.

## Installation

build and install the gem: 

```
gem build reqverify.gemspec
gem install reqverify-1.0.1.gem
```

## Tests

launch the test suite by typing

```
rake
```

## TODO

- [ ] Add delete part in reqvp executable
- [ ] create a GUI to explore requirement traceability

## License 

[BSD-3 LICENSE](LICENSE)
