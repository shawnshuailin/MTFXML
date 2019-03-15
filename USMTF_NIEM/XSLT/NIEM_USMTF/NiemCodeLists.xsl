<?xml version="1.0" encoding="UTF-8"?>
<!--
/* 
 * Copyright (C) 2017 JD NEUSHUL
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:term="http://release.niem.gov/niem/localTerminology/3.0/"
    xmlns:ism="urn:us:gov:ic:ism" xmlns:appinfo="http://release.niem.gov/niem/appinfo/4.0/" xmlns:ddms="http://metadata.dod.mil/mdr/ns/DDMS/2.0/" xmlns:inf="urn:mtf:mil:6040b:appinfo"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <!--<xsl:include href="USMTF_Utility.xsl"/>-->

    <xsl:variable name="enumerations_xsd" select="document('../../XSD/Baseline_Schema/fields.xsd')/*:schema//*:simpleType[*:restriction[@base = 'xsd:string'][*:enumeration]]"/>
    <xsl:variable name="sdir" select="'../../XSD/'"/>
    <xsl:variable name="cfld_changes" select="document(concat($sdir, 'Refactor_Changes/FieldChanges.xml'))/FieldChanges"/>
    <xsl:variable name="norm_enum_types" select="document(concat($sdir, 'Refactor_Changes/M201804C0IF-EnumerationSimpleTypes.xml'))/EnumerationTypes"/>
    <xsl:variable name="norm_enums" select="document(concat($sdir, 'Refactor_Changes/M201804C0IF-Enumerations.xml'))/Enumerations"/>
    <!--Output-->
    <xsl:variable name="codelistout" select="'../../XSD/Analysis/Maps/CodeLists.xml'"/>
    <xsl:variable name="codelistxsdout" select="'../../XSD/Analysis/Normalized/CodeLists.xsd'"/>
    <!--Map Original Enumerated SimpleTypes to an XML fragment-->
    <xsl:variable name="codelists">
        <xsl:for-each select="$enumerations_xsd">
            <xsl:sort select="@name"/>
            <xsl:variable name="mtfname" select="@name"/>
            <xsl:variable name="ffirn">
                <xsl:value-of select="*:annotation/*:appinfo/*:FieldFormatIndexReferenceNumber"/>
            </xsl:variable>
            <xsl:variable name="fud">
                <xsl:value-of select="*:annotation/*:appinfo/*:FudNumber"/>
            </xsl:variable>
            <xsl:variable name="niemsimpletype" select="$norm_enum_types/EnumerationType[@ffirn = $ffirn][@fud = $fud]"/>
            <xsl:variable name="changeto" select="$cfld_changes/CodeList[@name = $mtfname]/@changeto"/>
            <xsl:variable name="niemsimpletypename" >
                <xsl:choose>
                    <xsl:when test="$niemsimpletype/@fudname">
                        <xsl:variable name="camelcasename">
                            <xsl:call-template name="CamelCase">
                                <xsl:with-param name="text" select="$niemsimpletype/@fudname"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="codeSimpleTypeName">
                            <xsl:with-param name="ntext" select="replace($camelcasename, ' ', '')"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="codeSimpleTypeName">
                            <xsl:with-param name="ntext" select="@name"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="niemelementname" select="substring-before($niemsimpletypename, 'SimpleType')"/>
            <xsl:variable name="niemcomplextype" select="concat($niemelementname, 'Type')"/>              
            <xsl:variable name="doc">
                <xsl:apply-templates select="*:annotation/*:documentation"/>
            </xsl:variable>
            <xsl:variable name="niemtypedoc">
                <xsl:choose>
                    <xsl:when test="$cfld_changes/CodeList[@name = $mtfname]">
                        <xsl:value-of select="$cfld_changes/CodeList[@name = $mtfname]/@doc"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$doc"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="niemelementdoc">
                <xsl:value-of select="replace($niemtypedoc, 'A data type', 'A data item')"/>
            </xsl:variable>
            <xsl:variable name="fappinfo">
                <xsl:apply-templates select="*:annotation/*:appinfo">
                    <xsl:with-param name="appattr" select="$niemsimpletype"/>
                </xsl:apply-templates>
            </xsl:variable>
            <Field niemelementname="{$niemelementname}" niemsimpletype="{$niemsimpletypename}" niemtype="{$niemcomplextype}" niemtypedoc="{$niemtypedoc}" niemelementdoc="{$niemelementdoc}"
                mtftype="{@name}" ffirn="{$ffirn}" fud="{$fud}">
                <info>
                    <xsl:for-each select="$fappinfo/*">
                        <xsl:copy-of select="." copy-namespaces="no"/>
                    </xsl:for-each>
                </info>
                <Codes>
                    <xsl:for-each select="*:restriction/*:enumeration">
                        <Code value="{@value}" dataItem="{*:annotation/*:appinfo/*:DataItem}" doc="{normalize-space(*:annotation/*:documentation/text())}"/>
                    </xsl:for-each>
                </Codes>
            </Field>
        </xsl:for-each>
       <!-- <xsl:for-each select="$norm_enum_types/*[@niemname = '.']">
            <xsl:variable name="frn" select="@ffirn"/>
            <xsl:variable name="fd" select="@fud"/>
            <xsl:variable name="nn">
                <xsl:call-template name="CamelCase">
                    <xsl:with-param name="text" select="@fudname"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="niemelname" select="replace($nn, ' ', '')"/>
            <xsl:variable name="niemcodestype">
                <xsl:call-template name="codeSimpleTypeName">
                    <xsl:with-param name="ntext" select="$niemelname"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="niemcodetype" select="replace($niemcodestype, 'CodeSimpleType', 'CodeType')"/>
            <xsl:variable name="typedoc">
                <xsl:choose>
                    <xsl:when test="starts-with(@fudexp, 'A data type for')">
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:when test="ends-with(@fudexp, 'Simple Type')">
                        <xsl:value-of select="concat('A data type for ', lower-case(substring-before(@fudexp, 'Simple Type')))"/>
                    </xsl:when>
                    <xsl:when test="ends-with(@fudexp, 'Type')">
                        <xsl:value-of select="concat('A data type for ', lower-case(substring-before(@fudexp, 'Type')))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('A data type for ', concat(lower-case(substring(@fudexp, 1, 1)), substring(@fudexp, 2)))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="eldoc">
                <xsl:value-of select="replace($typedoc, 'A data type', 'A data item')"/>
            </xsl:variable>
            <Field niemsimpletype="{$niemcodestype}" niemtype="{$niemcodetype}" niemtypedoc="{$typedoc}" niemelementdoc="{$eldoc}" ffirn="{@ffirn}" fud="{@fud}">
                <xs:appinfo>
                    <inf:Field name="{@fudname}" explanation="{@fudexp}" version="{@version}" versiondate="{@versiondate}" dist="{@dist}" ffirn="{@ffirn}" fud="{@fud}">
                        <xsl:apply-templates select="@abbrev" mode="hascontent"/>
                        <xsl:apply-templates select="@reldoc" mode="hascontent"/>
                        <xsl:apply-templates select="@cmRemark" mode="hascontent"/>
                        <xsl:apply-templates select="@remarks" mode="hascontent"/>
                    </inf:Field>
                </xs:appinfo>
                <Codes>
                    <xsl:for-each select="$norm_enums/Enumeration[@ffirn = $frn][@fud = $fd]">
                        <xsl:sort select="@seq"/>
                        <Code value="{@value}" dataItem="{@datacode}" doc="{@doc}"/>
                    </xsl:for-each>
                </Codes>
            </Field>
        </xsl:for-each>-->
    </xsl:variable>

    <xsl:variable name="codelisttypes">
        <xsl:for-each select="$codelists/*">
            <xsl:variable name="n" select="@niemelementname"/>
            <xsl:variable name="codes" select="Codes"/>
            <xs:simpleType name="{@niemsimpletype}">
                <xs:annotation>
                    <xs:documentation ism:classification="U" ism:ownerProducer="USA" ism:noticeType="{concat('DoD-Dist-',*:appinfo/*:Field/@dist)}">
                        <xsl:value-of select="@niemtypedoc"/>
                    </xs:documentation>
                    <xsl:if test="*:appinfo/*">
                        <xs:appinfo>
                            <xsl:for-each select="*:appinfo/*">
                                <xsl:copy copy-namespaces="no">
                                    <xsl:apply-templates select="./@*" mode="appinfoatts"/>
                                </xsl:copy>
                            </xsl:for-each>
                        </xs:appinfo>
                    </xsl:if>
                </xs:annotation>
                <xs:restriction base="xs:string">
                    <xsl:for-each select="$codes/Code">
                        <xs:enumeration value="{@value}">
                            <xs:annotation>
                                <xs:documentation>
                                    <xsl:value-of select="@doc"/>
                                </xs:documentation>
                            </xs:annotation>
                        </xs:enumeration>
                    </xsl:for-each>
                </xs:restriction>
            </xs:simpleType>
            <xs:complexType name="{@niemtype}">
                <xs:annotation>
                    <xs:documentation ism:classification="U" ism:ownerProducer="USA" ism:noticeType="{concat('DoD-Dist-',*:appinfo/*:Field/@dist)}">
                        <xsl:value-of select="@niemtypedoc"/>
                    </xs:documentation>
                    <xs:appinfo>
                        <xsl:for-each select="*:appinfo/*">
                            <xsl:copy-of select="." copy-namespaces="no"/>
                        </xsl:for-each>
                    </xs:appinfo>
                </xs:annotation>
                <xs:simpleContent>
                    <xs:extension base="{@niemsimpletype}">
                        <xs:attributeGroup ref="structures:SimpleObjectAttributeGroup"/>
                    </xs:extension>
                </xs:simpleContent>
            </xs:complexType>
            <!--<xsl:if test="@niemelementname and count(preceding-sibling::*[@niemelementname=$n])=0">-->
            <xsl:if test="@niemelementname">
                <xs:element name="{@niemelementname}" type="{@niemtype}" nillable="true">
                    <xs:annotation>
                        <xs:documentation ism:classification="U" ism:ownerProducer="USA" ism:noticeType="{concat('DoD-Dist-',*:appinfo/*:Field/@dist)}">
                            <xsl:value-of select="@niemelementdoc"/>
                        </xs:documentation>
                        <xs:appinfo>
                            <xsl:for-each select="*:appinfo/*">
                                <xsl:copy-of select="." copy-namespaces="no"/>
                            </xsl:for-each>
                        </xs:appinfo>
                    </xs:annotation>
                </xs:element>
            </xsl:if>
            <!--</xsl:if>-->
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="codelistxsd">
        <xsl:for-each select="$codelisttypes/*:simpleType">
            <xsl:sort select="@name"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
        <xsl:for-each select="$codelisttypes/*:complexType">
            <xsl:sort select="@name"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
        <xsl:for-each select="$codelisttypes/*:element">
            <xsl:sort select="@name"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:variable>

    <!-- <xsl:template match="@*" mode="copy">
        <xsl:if test=". != '.'">
            <xsl:attribute name="{name()}">
                <xsl:value-of select="."/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>-->

    <xsl:template match="*" mode="enum">
        <xs:enumeration value="{@datacode}">
            <xs:annotation>
                <xs:documentation>
                    <xsl:value-of select="@doc"/>
                </xs:documentation>
            </xs:annotation>
        </xs:enumeration>
    </xsl:template>

    <xsl:template name="codelistmain">
        <xsl:result-document href="{$codelistxsdout}">
            <xs:schema xmlns="urn:mtf:mil:6040b:niem:mtf:fields" xmlns:ism="urn:us:gov:ic:ism" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ct="http://release.niem.gov/niem/conformanceTargets/3.0/" xmlns:structures="http://release.niem.gov/niem/structures/4.0/"
                xmlns:term="http://release.niem.gov/niem/localTerminology/3.0/" xmlns:appinfo="http://release.niem.gov/niem/appinfo/4.0/" xmlns:inf="urn:mtf:mil:6040b:appinfo"
                xmlns:ddms="http://metadata.dod.mil/mdr/ns/DDMS/2.0/" targetNamespace="urn:mtf:mil:6040b:niem:mtf:fields"
                ct:conformanceTargets="http://reference.niem.gov/niem/specification/naming-and-design-rules/4.0/#ReferenceSchemaDocument" xml:lang="en-US" elementFormDefault="unqualified"
                attributeFormDefault="unqualified" version="1.0">
                <xs:import namespace="urn:us:gov:ic:ism" schemaLocation="IC-ISM.xsd"/>
                <xs:import namespace="http://release.niem.gov/niem/structures/4.0/" schemaLocation="../NIEM/structures.xsd"/>
                <xs:import namespace="http://release.niem.gov/niem/localTerminology/3.0/" schemaLocation="../NIEM/localTerminology.xsd"/>
                <xs:import namespace="http://release.niem.gov/niem/appinfo/4.0/" schemaLocation="../NIEM/appinfo.xsd"/>
                <xs:import namespace="urn:mtf:mil:6040b:appinfo" schemaLocation="../NIEM/mtfappinfo.xsd"/>
                <xs:annotation>
                    <xs:documentation>
                        <xsl:text>Code Lists for MTF Messages</xsl:text>
                    </xs:documentation>
                </xs:annotation>
                <xsl:for-each select="$codelistxsd/*:simpleType">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:if test="not(preceding-sibling::*:simpleType/@name = $n)">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$codelistxsd/*:complexType">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:if test="not(preceding-sibling::*:complexType/@name = $n)">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$codelistxsd/*:element">
                    <xsl:sort select="@name"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xs:schema>
        </xsl:result-document>
        <xsl:result-document href="{$codelistout}">
            <CodeLists xmlns:xs="http://www.w3.org/2001/XMLSchema">
                <xsl:copy-of select="$codelists"/>
            </CodeLists>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
