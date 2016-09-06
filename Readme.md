VODSL sample models
===================

This project contains some models defined in VODSL that can be edited using the
eclipse plug-in defined in the [VODSL project](https://github.com/pahjbo/vodsl)
which should be consulted for information on how to build and install the plug-in.

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

The models
----------

The models in this project have been derived using
[this XSLT](vo-dml2dsl.xsl) to transform the VODML that can be found in 
https://volute.g-vo.org/viewvc/volute/trunk/projects/dm/ - although a certain 
amount of hand editing may also have been required to remove the gross errors -
however, in general there are many errors remaining in these models.

The fundamental model that should included within all of the other models is the 
[IVOA.vodsl](./IVOA.vodsl) model to make the models IVOA compliant.
