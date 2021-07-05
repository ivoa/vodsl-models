<?xml version="1.0" encoding="UTF-8"?>
<!--
This XSLT script transforms an XSD schema to the VODSL representation. It is optimized towards converting the IVOA registry schemata,
so does not necessarily work well in the general case. In any case it is not guaranteed to produced completely valid vodsl - some hand editing 
will probably be necessary.

In particular

* it has no way to recognise when otype members should be references or compositions
* some dtypes get created from a xs:simpleType which extend primitives - (particularly when the xs:simpleType just adds an xs:attribute)


might be able to make more use of subsets

Paul Harrison

-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:vm="http://www.ivoa.net/xml/VOMetadata/v0.1"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:vo-dml="http://www.ivoa.net/xml/VODML/v1">
  
  <xsl:output method="text" encoding="UTF-8" indent="no" />
  
  <xsl:param name="model.name" select="'silly'"/>
  
  <xsl:strip-space elements="*" />
  
  <xsl:key name="element" match="*//xs:complexType" use="."/>
  <xsl:key name="simpletype" match="*//xs:simpleType" use="."/>  

  
  <xsl:variable name="targetprefix" select="//vm:targetPrefix"/> <!-- this is a bit of a cheat that works with resource schema - should find from analysing the attributes of xs:schema -->
  <xsl:variable name="packages" select="//package/vodml-id"/>
  <xsl:variable name="sq"><xsl:text>'</xsl:text></xsl:variable>
  <xsl:variable name="dq"><xsl:text>"</xsl:text></xsl:variable>
  <xsl:variable name='nl'><xsl:text>
</xsl:text></xsl:variable>
  <xsl:variable name='lt'><xsl:text disable-output-escaping="yes">&lt;</xsl:text></xsl:variable>
  <xsl:variable name='gt'><xsl:text disable-output-escaping="yes">&gt;</xsl:text></xsl:variable>
  

  <xsl:variable name="modname">
    <xsl:choose>
      <xsl:when test="/xs:schema/xs:annotation/xs:appinfo/vm:schemaName"><xsl:value-of select="/xs:schema/xs:annotation/xs:appinfo/vm:schemaName"  /></xsl:when>
      <xsl:otherwise><xsl:value-of select="/vo-dml:model/name"  /></xsl:otherwise> <!-- should pass name -->
    </xsl:choose>
  </xsl:variable>
   

  <xsl:template match="/">
  <xsl:message>Starting DSL</xsl:message>
    <xsl:apply-templates select="xs:schema"/>
  </xsl:template>
  
  <xsl:template match="xs:schema">  
  <xsl:message>Found model <xsl:value-of select="$modname"/></xsl:message>
model <xsl:value-of select="$modname"/> (<xsl:value-of select="@version"/>) 
	  <xsl:apply-templates select="xs:annotation"/>
      include "IVOA-v1.0.vodsl"
     <xsl:apply-templates select="xs:import"/>
     <!-- define any local enums -->
      <xsl:apply-templates select="//xs:simpleType[not(@name) and xs:restriction/xs:enumeration]"/>
      <xsl:apply-templates select="* except (xs:annotation|xs:import)"/>
  </xsl:template>
 
 <xsl:template match="xs:import">
   <xsl:analyze-string regex="/([^/]+)\.xsd" select="@schemaLocation">
     <xsl:matching-substring>
       include "<xsl:value-of select="regex-group(1)"/>.vodsl"
     </xsl:matching-substring>
    
   </xsl:analyze-string>
   
 </xsl:template> 
  

<xsl:template match="author">
   <xsl:value-of select="concat($nl,' author ',$dq,.,$dq)"/>
</xsl:template>

<xsl:template match="identifier">
   <xsl:value-of select="concat($nl,$lt,.,$gt)"/>
</xsl:template>


  <xsl:template match="package"> <!-- will not be any of these -->
package <xsl:value-of select="concat(name,' ')"/> <xsl:apply-templates select= "description"/>
{
      <xsl:apply-templates select="* except (vodml-id|description|name)" />
}
  </xsl:template>
  
 
<!-- remove the local namespace -->  
  <xsl:template name='localref'> 
     <xsl:param name="ref"/>
     <xsl:choose>
        <xsl:when test="substring-before( $ref,':') = $targetprefix">
           <xsl:value-of select="substring-after($ref,':')"/>
        </xsl:when>
        <xsl:otherwise>
           <!-- <xsl:value-of select="translate(.,':','.')"/> --> 
           <xsl:value-of select="$ref"/>
        </xsl:otherwise>
     </xsl:choose>
     
  </xsl:template>

<xsl:template match="xs:complexType[xs:simpleContent]">
  <xsl:value-of select="$nl"/><xsl:if test="@abstract">abstract </xsl:if>dtype <xsl:value-of select="@name"/><xsl:text> </xsl:text>
  <xsl:apply-templates select= "xs:simpleContent/xs:extension"/>
  <xsl:call-template name="doAnnotation"/>
  {   <xsl:apply-templates select="xs:simpleContent/xs:extension/*"/>
  }
</xsl:template>


<xsl:template match="xs:complexType[xs:complexContent]">
  <xsl:value-of select="$nl"/><xsl:if test="@abstract">abstract </xsl:if>otype <xsl:value-of select="@name"/><xsl:text> </xsl:text>
  <xsl:apply-templates select= "xs:extension"/>
  <xsl:call-template name="doAnnotation"/>
  {   <xsl:apply-templates select="xs:extension/*"/>
  }
</xsl:template>


<xsl:template match="xs:complexType">
  <xsl:value-of select="$nl"/><xsl:if test="@abstract">abstract </xsl:if>otype <xsl:value-of select="@name"/><xsl:text> </xsl:text>
  <xsl:call-template name="doAnnotation"/>
  {   <xsl:apply-templates select="* except xs:annotation"/>
  }
</xsl:template>

<xsl:template match="xs:sequence">
    <xsl:apply-templates select="*"/>
</xsl:template>
<xsl:template match="xs:simpleType[@name and xs:restriction/xs:enumeration]">
enum <xsl:value-of select="@name"/><xsl:text> </xsl:text> 
<xsl:apply-templates select="xs:annotation"/>
{
<xsl:apply-templates select="xs:restriction/*"/>
}

</xsl:template>
<xsl:template match="xs:simpleType[not(@name) and xs:restriction/xs:enumeration]">
enum <xsl:value-of select="concat(../@name, '_enum')"/><xsl:text> </xsl:text> 
<xsl:apply-templates select="xs:annotation"/>
{
<xsl:apply-templates select="xs:restriction/*"/>
}

</xsl:template>
<xsl:template match="xs:enumeration">
<xsl:value-of select="@value"/><xsl:text> </xsl:text><xsl:apply-templates select="xs:annotation"/>
<xsl:if test="position() != last()">,
</xsl:if>
</xsl:template>

<xsl:template match="xs:simpleType[@name and not( xs:restriction/xs:enumeration)]">
  <xsl:value-of select="$nl"/>primitive <xsl:value-of select="@name"/><xsl:text> </xsl:text>
  <xsl:apply-templates select="* except (xs:annotation)"/>
  <xsl:call-template name="doAnnotation"/>
</xsl:template>



<xsl:template match="xs:simpleType"><!-- does this ever match -->
  <xsl:value-of select="$nl"/><xsl:if test="@abstract">abstract </xsl:if>dtype <xsl:value-of select="@name"/><xsl:text> </xsl:text>
  <xsl:call-template name="doAnnotation"/>
  {   
  }
</xsl:template>

<xsl:template name="doAnnotation">
<!-- deal with the annotation not being present -->
     <xsl:choose>
         <xsl:when test="xs:annotation"><xsl:apply-templates select="xs:annotation" /></xsl:when>
         <xsl:otherwise><xsl:text> "" </xsl:text></xsl:otherwise>
     </xsl:choose>
</xsl:template>

<xsl:template match ="xs:annotation">
  <xsl:text> "</xsl:text><xsl:if test="not(matches(text(),'^\s*TODO'))"><xsl:value-of select='translate(.,$dq,$sq)'/></xsl:if><xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="xs:element[@name]">
  <xsl:message>element <xsl:value-of select="@name"/></xsl:message>
  <xsl:text>
        </xsl:text>
  <xsl:value-of select="concat(@name, ': ')"/> 
  <xsl:apply-templates select="@type"/><xsl:text> </xsl:text> 
  <xsl:call-template name="multiplicity"/><xsl:text> </xsl:text> 
  <xsl:apply-templates select="xs:annotation"/>
  <xsl:text>;</xsl:text>
</xsl:template>
<xsl:template match="xs:element[@ref]">
  <xsl:message>element ref <xsl:value-of select="@ref"/></xsl:message> <!-- TODO is this the right thing -->
  <xsl:text>
        </xsl:text>
  <xsl:value-of select="concat(@ref, ' references ')"/> 
  <xsl:apply-templates select="@type"/><xsl:text> </xsl:text> 
  <xsl:call-template name="multiplicity"/><xsl:text> </xsl:text> 
  <xsl:apply-templates select="xs:annotation"/>
  <xsl:text>;</xsl:text>
</xsl:template>
<xsl:template match="xs:attribute">
  <xsl:message>attribute <xsl:value-of select="@name"/></xsl:message>  
  <xsl:text>
        </xsl:text>
  <xsl:value-of select="concat(@name, ': ')"/> 
  <xsl:choose>
     <xsl:when test="xs:simpleType/xs:restriction/xs:enumeration"><xsl:value-of select="concat(@name,'_enum')"/></xsl:when>
     <xsl:otherwise><xsl:apply-templates select="@type"/></xsl:otherwise>
  </xsl:choose>
  <xsl:text> </xsl:text> 
  <xsl:choose>
  <xsl:when test="@use='optional'">@?</xsl:when>
  </xsl:choose>
  <xsl:text> </xsl:text> 
  <xsl:apply-templates select="xs:annotation"/>
  <xsl:text>;</xsl:text>
</xsl:template>
  

<xsl:template name="multiplicity">
   <xsl:choose>
   <xsl:when test="not(@minOccurs) and not(@maxOccurs)"><!-- do nothing --></xsl:when>   
   <xsl:when test="number(@minOccurs) eq 1 and number(@maxOccurs) eq 1"><!-- do nothing --></xsl:when>
   <xsl:when test="number(@minOccurs) eq 0 and (number(@maxOccurs) eq 1 or not(@maxOccurs))"> @? </xsl:when>
   <xsl:when test="number(@minOccurs) eq 0 and @maxOccurs='unbounded'"> @* </xsl:when>
   <xsl:when test="(not(@minOccurs) or number(@minOccurs) eq 1) and @maxOccurs='unbounded'"> @+ </xsl:when>
   <xsl:otherwise><xsl:value-of select="concat('@[',@minOccurs,'..', @maxOccurs,']')"/></xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="typeconv">
  <xsl:param name="t"/>
  <xsl:choose>
     <xsl:when test="$t = 'xs:token' or $t = 'xs:string' or $t = 'xs:NMTOKEN'">ivoa:string</xsl:when>
     <xsl:when test="$t = 'xs:anyURI'">ivoa:anyURI</xsl:when>
     <xsl:when test="$t = 'xs:float'">ivoa:real</xsl:when>
     <xsl:when test="$t = 'xs:integer'">ivoa:integer</xsl:when>
     <xsl:when test="$t = 'xs:boolean'">ivoa:boolean</xsl:when>
     <xsl:when test="$t = 'xs:dateTime'">ivoa:datetime</xsl:when>
     <xsl:otherwise>
         <xsl:call-template name="localref">
      <xsl:with-param name="ref" select = "$t" />
    </xsl:call-template>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="@type">
    <xsl:call-template name="typeconv">
      <xsl:with-param name="t" select = "." />
    </xsl:call-template>
</xsl:template>
<xsl:template match="@base">
    <xsl:call-template name="typeconv">
      <xsl:with-param name="t" select = "." />
    </xsl:call-template>
</xsl:template>


<xsl:template match="xs:extension">
  <xsl:text> -&gt; </xsl:text><xsl:apply-templates select="@base"/>
</xsl:template>

<xsl:template match="xs:restriction[not(xs:enumeration)]">
  <xsl:text> -&gt; </xsl:text><xsl:apply-templates select="@base"/>
</xsl:template>


<xsl:template match="semanticconcept">
<xsl:text> semantic "</xsl:text><xsl:value-of select="topConcept"/><xsl:text>" in "</xsl:text><xsl:value-of select="vocabularyURI"/><xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="constraint[@xsi:type='vo-dml:SubsettedRole']"><!-- FIXME these apply to attributes...I think.... -->
<xsl:text> subsets</xsl:text> 
</xsl:template>



<xsl:template match="text()|*">
  <xsl:value-of select="."/>
</xsl:template>

 <!-- catchall to indicate where there might be missed element to highlight when VODML might have changed
<xsl:template match="*">
  <xsl:value-of select="concat('***',name(.),'*** ')"/>
   <xsl:apply-templates/>
</xsl:template>

-->

</xsl:stylesheet>