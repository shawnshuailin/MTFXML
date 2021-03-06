<?xml version="1.0" encoding="UTF-8"?>
<!--
/* 
 * Copyright (C) 2019 JD NEUSHUL
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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mtfappinfo="urn:int:nato:ncdf:mtf:appinfo" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="srcpath" select="'../../XSD/NCDF_MTF/'"/>
    <xsl:variable name="Outdir" select="'../../XSD/IEPD/'"/>
    <xsl:variable name="ALLMTF" select="document(concat($srcpath, 'NCDF_MTF.xsd'))"/>
    <xsl:variable name="appinf" select="document(concat($srcpath, 'ncdf/utility/appinfo/4.0/appinfo.xsd'))"/>
    <xsl:variable name="struct" select="document(concat($srcpath, 'ncdf/utility/structures/4.0/structures.xsd'))"/>
    <xsl:variable name="locterm" select="document(concat($srcpath, 'ncdf/localTerminology.xsd'))"/>
    <xsl:variable name="mtfappinf" select="document(concat($srcpath, 'ncdf/mtfappinfo.xsd'))"/>
    <xsl:variable name="nsmxsd" select="document(concat($srcpath, 'nsm/nsm-iep.xsd'))"/>
    <xsl:variable name="q" select="'&quot;'"/>
    <xsl:variable name="lt" select="'&lt;'"/>
    <xsl:variable name="gt" select="'&gt;'"/>
    <xsl:variable name="cm" select="','"/>
    <xsl:variable name="ALLIEP">
        <xsl:apply-templates select="$ALLMTF/xs:schema/*" mode="milstd"/>
    </xsl:variable>
    <xsl:variable name="iep-xsd-template">
        <xs:schema xmlns="urn:int:nato:ncdf:mtf" xmlns:inf="urn:int:nato:ncdf:mtf:appinfo" xmlns:nsm="urn:int:nato:ncdf:nsm" xmlns:xs="http://www.w3.org/2001/XMLSchema" targetNamespace="urn:int:nato:ncdf:mtf" xml:lang="en-US" elementFormDefault="unqualified"
            attributeFormDefault="unqualified" version="1.0">
            <xs:import namespace="urn:int:nato:ncdf:nsm" schemaLocation="ext/nsm/nsm-iep.xsd"/>
        </xs:schema>
    </xsl:variable>

    <xsl:template name="main">
        <!--Create REF Folder-->
       <xsl:call-template name="RefFolder"/>
        <!--CREATE MSG IEPD AND COPY TO MSG IEPD FOLDER-->
        <xsl:for-each select="$ALLIEP/xs:element[xs:annotation/xs:appinfo/*:Msg]">
            <xsl:sort select="xs:annotation/xs:appinfo/*:Msg/@mtfid"/>
            <xsl:variable name="t" select="@type"/>
            <xsl:variable name="mid" select="translate(xs:annotation/xs:appinfo/*:Msg/@mtfid, ' .', '')"/>
            <xsl:call-template name="ExtractIepSchema">
                <xsl:with-param name="msgelement" select="."/>
                <xsl:with-param name="outdir" select="concat($Outdir, 'xml/xsd/')"/>
            </xsl:call-template>
        </xsl:for-each>-->
    </xsl:template>
    
    <xsl:template name="RefFolder">
        <!--COPY REF XSD TO ext FOLDER-->
        <xsl:result-document href="{concat($Outdir,'xml/xsd/ext/NCDF_MTF_REF.xsd')}">
            <xsl:copy-of select="$ALLMTF"/>
        </xsl:result-document>
        <!--CREATE CUMULATIVE IEPD AND COPY TO EXT FOLDER-->
        <xsl:result-document href="{concat($Outdir,'xml/xsd/ext/NCDF_MTF.xsd')}">
            <xs:schema xmlns="urn:int:nato:ncdf:mtf" xmlns:inf="urn:int:nato:ncdf:mtf:appinfo" xmlns:xs="http://www.w3.org/2001/XMLSchema" targetNamespace="urn:int:nato:ncdf:mtf"
                xml:lang="en-US" elementFormDefault="unqualified" attributeFormDefault="unqualified" version="1.0">
                <xsl:copy-of select="$ALLIEP" copy-namespaces="no"/>
            </xs:schema>
        </xsl:result-document>
        <!--COPY NCDF RESOURCES TO EXT FOLDER-->
        <xsl:result-document href="{concat($Outdir,'xml/xsd/ext/ncdf/utility/appinfo/4.0/appinfo.xsd')}">
            <xsl:copy-of select="$mtfappinf/xs:schema"/>
        </xsl:result-document>
        <xsl:result-document href="{concat($Outdir,'xml/xsd/ext/ncdf/utility/structures/4.0/structures.xsd')}">
            <xsl:copy-of select="$struct/xs:schema"/>
        </xsl:result-document>
        <xsl:result-document href="{concat($Outdir,'xml/xsd/ext/ncdf/localTerminology.xsd')}">
            <xsl:copy-of select="$locterm/xs:schema"/>
        </xsl:result-document>
        <xsl:result-document href="{concat($Outdir,'xml/xsd/ext/ncdf/appinfo.xsd')}">
            <xsl:copy-of select="$appinf/xs:schema"/>
        </xsl:result-document>
        <xsl:result-document href="{concat($Outdir,'xml/xsd/ext/nsm/nsm-iep.xsd')}">
            <xsl:copy-of select="$nsmxsd/xs:schema"/>
        </xsl:result-document>
    </xsl:template>

    <!--Exctract IEPD-->
    <xsl:template name="ExtractIepSchema">
        <xsl:param name="msgelement"/>
        <xsl:param name="outdir"/>
        <xsl:variable name="mid" select="translate($msgelement/xs:annotation/xs:appinfo/*:Msg/@mtfid, ' .', '')"/>
        <xsl:variable name="t" select="$msgelement/@type"/>
        <xsl:result-document href="{$outdir}/{concat($mid,'-iep.xsd')}">
            <xsl:for-each select="$iep-xsd-template/*">
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="identity"/>
                    <xsl:apply-templates select="*" mode="identity"/>
                <xs:annotation>
                    <xs:documentation>
                        <xsl:value-of select="concat($msgelement/*:annotation/*:appinfo/*:Msg/@mtfname, ' MESSAGE SCHEMA')"/>
                    </xs:documentation>
                    <xsl:copy-of select="$msgelement/*:annotation/*:appinfo"/>
                </xs:annotation>
                <xsl:copy-of select="$msgelement" copy-namespaces="no"/>
                <xsl:copy-of select="$ALLIEP/*:complexType[@name = $t]" copy-namespaces="no"/>
                <xsl:variable name="msgnodes">
                    <xsl:for-each select="$ALLIEP/*:complexType[@name = $t]//*[@ref]">
                        <xsl:variable name="n" select="@ref"/>
                        <xsl:apply-templates select="$ALLIEP/*[@name = $n]" mode="iterateNode">
                            <xsl:with-param name="namelist">
                                <node name="{$n}"/>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:for-each>
                    <xsl:for-each select="$ALLIEP/*:complexType[@name = $t]//*[@base]">
                        <xsl:variable name="n" select="@base"/>
                        <xsl:apply-templates select="$ALLIEP/*[@name = $n]" mode="iterateNode">
                            <xsl:with-param name="namelist">
                                <node name="{$n}"/>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:for-each>
                    <xsl:for-each select="$ALLIEP/*:complexType[@name = $t]//*[@type]">
                        <xsl:variable name="n" select="@type"/>
                        <xsl:apply-templates select="$ALLIEP/*[@name = $n]" mode="iterateNode">
                            <xsl:with-param name="namelist">
                                <node name="{$n}"/>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:for-each select="$msgnodes/*:complexType[not(@name = $t)]">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:if test="count(preceding-sibling::*:complexType[@name = $n]) = 0">
                        <xsl:copy-of select="." copy-namespaces="no"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$msgnodes/*:simpleType">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:if test="count(preceding-sibling::*:simpleType[@name = $n]) = 0">
                        <xsl:copy-of select="." copy-namespaces="no"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$msgnodes/*:element[not(@name = $msgelement/@name)]">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:if test="count(preceding-sibling::*:element[@name = $n]) = 0">
                        <xsl:copy-of select="." copy-namespaces="no"/>
                    </xsl:if>
                </xsl:for-each>
                </xsl:copy>
            </xsl:for-each>
        </xsl:result-document>
        
    </xsl:template>

    <xsl:template match="*" mode="iterateNode">
        <xsl:param name="namelist"/>
        <xsl:variable name="node" select="."/>
        <xsl:copy-of select="$node" copy-namespaces="no"/>
        <xsl:for-each select="$node//@*[name() = 'ref' or name() = 'type' or name() = 'base' or name() = 'substitutionGroup' or name() = 'abstract'][not(. = $node/@name)]">
            <xsl:variable name="n">
                <xsl:value-of select="."/>
            </xsl:variable>
            <xsl:if test="not($namelist/node[@name = $n])">
                <xsl:apply-templates select="$ALLIEP/*[@name = $n]" mode="iterateNode">
                    <xsl:with-param name="namelist">
                        <xsl:copy-of select="$namelist"/>
                        <node name="{$n}"/>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!--Convert to IEPD-->
    <xsl:template match="*" mode="milstd">
        <xsl:variable name="r" select="@ref"/>
        <xsl:choose>
            <xsl:when test="parent::xs:schema and xs:annotation/xs:appinfo/*:Choice">
                <xs:element name="{@name}" type="{@type}">
                    <xsl:copy-of select="xs:annotation" copy-namespaces="no"/>
                    <xsl:for-each select="$ALLMTF//xs:element[@substitutionGroup = $r]">
                        <xsl:variable name="t" select="@type"/>
                        <xsl:variable name="n" select="@name"/>
                        <xsl:variable name="match">
                            <xsl:copy-of select="$ALLMTF/xs:schema/xs:element[@name = $n][@type = $t]"/>
                        </xsl:variable>
                        <xs:element ref="{@name}">
                            <xsl:copy-of select="$match/*/xs:annotation" copy-namespaces="no"/>
                        </xs:element>
                    </xsl:for-each>
                </xs:element>
            </xsl:when>
            <xsl:when test="xs:annotation/xs:appinfo/*:Choice">
                <xs:choice>
                    <xsl:copy-of select="@minOccurs"/>
                    <xsl:copy-of select="@maxOccurs"/>
                    <xsl:copy-of select="xs:annotation" copy-namespaces="no"/>
                    <xsl:for-each select="$ALLMTF//xs:element[@substitutionGroup = $r]">
                        <xsl:variable name="t" select="@type"/>
                        <xsl:variable name="n" select="@name"/>
                        <xsl:variable name="match">
                            <xsl:copy-of select="$ALLMTF/xs:schema/xs:element[@name = $n][@type = $t]"/>
                        </xsl:variable>
                        <xs:element ref="{@name}">
                            <xsl:copy-of select="$match/*/xs:annotation" copy-namespaces="no"/>
                        </xs:element>
                    </xsl:for-each>
                </xs:choice>
            </xsl:when>
            <xsl:when test="name() = 'xs:sequence' and count(*) = 1 and *[1][name() = 'xs:choice']">
                <xsl:apply-templates select="*" mode="milstd"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*" mode="milstd"/>
                    <xsl:apply-templates select="*" mode="milstd"/>
                    <xsl:apply-templates select="text()" mode="milstd"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="@substitutionGroup" mode="milstd"/>
    <xsl:template match="@*" mode="milstd">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="text()" mode="milstd">
        <xsl:copy-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="xs:complexType/xs:complexContent" mode="milstd">
        <xsl:apply-templates select="xs:extension/*" mode="milstd"/>
    </xsl:template>
    <xsl:template match="xs:schema/*[@type = 'GeneralTextType']" mode="milstd">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@name"/>
            <xsl:copy-of select="xs:annotation" copy-namespaces="no"/>
            <xs:complexType>
                <xs:sequence>
                    <xs:element name="TextIndicator" minOccurs="1" maxOccurs="1" fixed="{xs:annotation/*/*/@positionName}"/>
                    <xs:element ref="FreeText" minOccurs="1" maxOccurs="1"/>
                </xs:sequence>
            </xs:complexType>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xs:schema/*[@type = 'HeadingInformationType']" mode="milstd">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@name"/>
            <xsl:copy-of select="xs:annotation" copy-namespaces="no"/>
            <xs:complexType>
                <xs:sequence>
                    <xs:element name="TextIndicator" minOccurs="1" maxOccurs="1" fixed="{xs:annotation/*/*/@textindicator}"/>
                    <xs:element ref="FreeText" minOccurs="1" maxOccurs="1"/>
                </xs:sequence>
            </xs:complexType>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xs:element[@name = 'MessageTextFormatIdentifierText']" mode="milstd">
        <xs:element name="MessageTextFormatIdentifierText" type="MessageTextFormatIdentifierTextType">
            <xsl:apply-templates select="@*[not(name() = 'ref')]" mode="milstd"/>
            <xsl:apply-templates select="*" mode="milstd"/>
        </xs:element>
    </xsl:template>
    <xsl:template match="xs:element[@name = 'StandardOfMessageTextFormatCode']" mode="milstd">
        <xs:element name="StandardOfMessageTextFormatCode" type="StandardOfMessageTextFormatCodeType">
            <xsl:apply-templates select="@*[not(name() = 'ref')]" mode="milstd"/>
            <xsl:apply-templates select="*" mode="milstd"/>
        </xs:element>
    </xsl:template>
    <xsl:template match="xs:element[@name = 'VersionOfMessageTextFormatText']" mode="milstd">
        <xs:element name="VersionOfMessageTextFormatText" type="VersionOfMessageTextFormatTextType">
            <xsl:apply-templates select="@*[not(name() = 'ref')]" mode="milstd"/>
            <xsl:apply-templates select="*" mode="milstd"/>
        </xs:element>
    </xsl:template>
    <xsl:template match="xs:attributeGroup[@ref = 'structures:SimpleObjectAttributeGroup']" mode="milstd">
        <xs:attributeGroup ref="nsm:SecurityAttributesOptionGroup"/>
    </xsl:template>
    <xsl:template match="xs:schema/xs:import" mode="milstd"/>
    <xsl:template match="xs:schema/xs:element[@abstract]" mode="milstd"/>
    <xsl:template match="*[contains(@ref, 'AugmentationPoint')]" mode="milstd"/>
    <xsl:template match="@abstract" mode="milstd"/>
    <xsl:template match="*" mode="identity">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*" mode="identity"/>
            <xsl:apply-templates select="text()" mode="identity"/>
            <xsl:apply-templates select="*" mode="identity"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*" mode="identity">
        <xsl:copy-of select="." copy-namespaces="no"/>
    </xsl:template>
    <xsl:template match="text()" mode="identity">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
</xsl:stylesheet>
