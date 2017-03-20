Datamodels in VODSL
========================

This directory contains a number of data models expressed in [VODSL](https://github.com/pahjbo/vodsl). There are a
number of the "standard" datamodels (discussed in more detail below) and a few example
models which aim to show some of the features of the VODSL markup.

 - [example.vodsl](./example.vodsl) shows some of the main constructs
 - [test.vodsl](./test.vodsl) has more extensive tests of features including some 
 deliberate mistakes to show the verification and error reporting features of the 
 editor.

IVOA Standard Models
--------------------

In addition to the above files there is a collection of IVOA datamodels expressed in VODSL.
In general these models are still in active development and so errors and inconsistencies are
to be expected.

The models have been translated from the [volute repository](https://volute.g-vo.org/svn/trunk/projects/dm/vo-dml/models) VO-DML
representation using the XSLT [vo-dml2dsl.xsl](./vo-dml2dsl.xsl) - the [ant build file](./build.xml) can be
used to redo this translation (and see exactly which original sources have been used). 
In some cases, minor edits have been made to the 
generated VODSL files to correct obvious errors in the original source.

The fundamental model that should included within all of the other models is the 
[IVOA.vodsl](./IVOA.vodsl) model to make the models IVOA compliant.


###STC

It should be noted that there are several versions of STC present 

- STC.vodsl is an attempt at a representation of the original STC version 1 - it has many errors, but
can be useful for other models that depend on STC v.1
- VO-DML-STC2.vodsl is an early attempt to represent STC version 2 in VO-DML - it too has many errors and is effectively
superseded by 
- STCCoordSys-2.0.vodsl, STCCoords-2.0.vodsl and STCTrans-2.0.vodsl which is a new modularisation of the STC2, and is error-free.


Editing in Eclipse
------------------

Once the plug-in has been installed then it is possible to create a "general" project
within eclipse and then create files with the `.vodsl` extension. To enable the VODSL
plug-in for a project you should select configure -> convert to Xtext project.
(Even if you do not perform this step explicitly, a pop-up will appear asking if you
want to enable Xtext when first trying to edit a  `.vodsl` file.)

As you save files the plug-in will generate [VODML](http://www.ivoa.net/documents/VODML)
files in the `src-gen` directory.

Note that the VODSL editor is still a work in progress and there are some 
[known issues](https://github.com/pahjbo/vodsl#known-issues-with-the-eclipse-editor).

