<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mtfappinfo="urn:mtf:mil:6040b:appinfo" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="srcpath" select="'../../../XSD/NIEM_MTF/'"/>
    <xsl:variable name="outdir" select="'../../../XSD/NIEM_IEPD/MILSTD_MTF/'"/>
    <xsl:variable name="AllMTF" select="document(concat($srcpath, 'NIEM_MTF.xsd'))"/>
    <xsl:variable name="MILSTDMTF">
        <xsl:apply-templates select="$AllMTF/xs:schema/*" mode="milstd"/>
    </xsl:variable>

    <xsl:template name="main">
        <xsl:result-document href="{concat($outdir,'MILSTD_MTF.xsd')}">
            <xs:schema xmlns="urn:mtf:mil:6040b:niem:mtf" 
                xmlns:ism="urn:us:gov:ic:ism" 
                xmlns:mtfappinfo="urn:mtf:mil:6040b:appinfo" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                targetNamespace="urn:mtf:mil:6040b:niem:mtf" xml:lang="en-US" 
                elementFormDefault="unqualified" attributeFormDefault="unqualified" version="1.0">
                <xs:import namespace="urn:us:gov:ic:ism" schemaLocation="../ext/ic-xml/ic-ism.xsd"/>
                <xsl:copy-of select="$MILSTDMTF" copy-namespaces="no"/>
            </xs:schema>
        </xsl:result-document>
        <xsl:for-each select="$MILSTDMTF//xs:element[xs:annotation/xs:appinfo/*:Msg][position()&gt;199]">
            <xsl:call-template name="ExtractMessageSchema">
                <xsl:with-param name="message" select="."/>
                <xsl:with-param name="outdir" select="concat($outdir, 'SepMsgs/')"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="*" mode="milstd">
        <xsl:variable name="r" select="@ref"/>
        <xsl:choose>
            <xsl:when test="parent::xs:schema and xs:annotation/xs:appinfo/*:Choice">
                <xs:element name="{@name}" type="{@type}">
                    <xsl:copy-of select="xs:annotation" copy-namespaces="no"/>
                        <xsl:for-each select="$AllMTF//xs:element[@substitutionGroup = $r]">
                            <xsl:variable name="t" select="@type"/>
                            <xsl:variable name="n" select="@name"/>
                            <xsl:variable name="match">
                                <xsl:copy-of select="$AllMTF/xs:schema/xs:element[@name = $n][@type = $t]"/>
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
                    <xsl:for-each select="$AllMTF//xs:element[@substitutionGroup = $r]">
                        <xsl:variable name="t" select="@type"/>
                        <xsl:variable name="n" select="@name"/>
                        <xsl:variable name="match">
                            <xsl:copy-of select="$AllMTF/xs:schema/xs:element[@name = $n][@type = $t]"/>
                        </xsl:variable>
                        <xs:element ref="{@name}">
                            <xsl:copy-of select="$match/*/xs:annotation" copy-namespaces="no"/>
                        </xs:element>
                    </xsl:for-each>
                </xs:choice>
            </xsl:when>
            <xsl:when test="xs:annotation/xs:appinfo/*:Choice">
                <xs:choice>
                    <xsl:copy-of select="xs:annotation" copy-namespaces="no"/>
                    <xsl:for-each select="$AllMTF//xs:element[@substitutionGroup = $r]">
                        <xsl:variable name="t" select="@type"/>
                        <xsl:variable name="n" select="@name"/>
                        <xsl:variable name="match">
                            <xsl:copy-of select="$AllMTF/xs:schema/xs:element[@name = $n][@type = $t]"/>
                        </xsl:variable>
                        <xs:element ref="{@name}">
                            <xsl:copy-of select="$match/*/xs:annotation" copy-namespaces="no"/>
                        </xs:element>
                    </xsl:for-each>
                </xs:choice>
            </xsl:when>
            <xsl:when test="name() = 'xs:sequence' and count(*) = 1 and *[1]/name() = 'xs:choice'">
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

    <xsl:template match="@ref" mode="getRefComplexType">
        <xsl:param name="xsd"/>
        <xsl:variable name="t" select="$xsd/xs:schema/xs:element[@name = .]/@type"/>
        <xsl:copy-of select="$xsd/xs:schema/xs:complexType[@name = $t]" copy-namespaces="no"/>
    </xsl:template>
    <xsl:template match="xs:complexType/xs:complexContent" mode="milstd">
        <xsl:apply-templates select="xs:extension/*" mode="milstd"/>
    </xsl:template>

    <!--<xsl:template match="*[contains(@name, 'AugmentationPoint')]" mode="milstd"/>-->

    <xsl:template match="xs:schema/*[@type = 'GeneralTextType']" mode="milstd">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@name"/>
            <xsl:copy-of select="xs:annotation" copy-namespaces="no"/>
            <xs:complexType>
                <xs:complexContent>
                    <xs:extension base="GeneralTextType">
                        <xs:sequence>
                            <xs:element name="TextIndicatorText" minOccurs="1" maxOccurs="1" fixed="{xs:annotation/*/*/@textindicator}"/>
                            <xs:element ref="FreeText" minOccurs="1" maxOccurs="1"/>
                        </xs:sequence>
                    </xs:extension>
                </xs:complexContent>
            </xs:complexType>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xs:schema/*[@type = 'HeadingInformationType']" mode="milstd">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@name"/>
            <xsl:copy-of select="xs:annotation" copy-namespaces="no"/>
            <xs:complexType>
                <xs:complexContent>
                    <xs:extension base="HeadingInformationType">
                        <xs:sequence>
                            <xs:element name="TextIndicatorText" minOccurs="1" maxOccurs="1" fixed="{xs:annotation/*/*/@textindicator}"/>
                            <xs:element ref="FreeText" minOccurs="1" maxOccurs="1"/>
                        </xs:sequence>
                    </xs:extension>
                </xs:complexContent>
            </xs:complexType>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xs:element[@ref = 'MessageIdentifier']" mode="milstd">
        <xsl:variable name="msgidset">
            <xsl:variable name="r" select="@ref"/>
            <xsl:variable name="t" select="$AllMTF/xs:schema/xs:element[@name = $r]/@type"/>
            <xsl:copy-of select="$AllMTF/xs:schema/xs:complexType[@name = $t]"/>
        </xsl:variable>
        <xs:element name="MessageIdentifier">
            <xsl:copy-of select="$msgidset/xs:annotation" copy-namespaces="no"/>
            <xs:complexType>
                <xsl:apply-templates select="$msgidset/*/xs:complexContent" mode="milstd"/>
            </xs:complexType>
        </xs:element>
    </xsl:template>
    <xsl:template match="xs:element[@ref = 'MessageTextFormatIdentifierText']" mode="milstd">
        <xs:element name="MessageTextFormatIdentifierText" type="MessageTextFormatIdentifierTextType">
            <xsl:apply-templates select="@*[not(name() = 'ref')]" mode="milstd"/>
            <xsl:apply-templates select="*" mode="milstd"/>
            <xsl:apply-templates select="text()" mode="milstd"/>
        </xs:element>
    </xsl:template>
    <xsl:template match="xs:element[@ref = 'StandardOfMessageTextFormatCode']" mode="milstd">
        <xs:element name="StandardOfMessageTextFormatCode" type="StandardOfMessageTextFormatCodeType">
            <xsl:apply-templates select="@*[not(name() = 'ref')]" mode="milstd"/>
            <xsl:apply-templates select="*" mode="milstd"/>
            <xsl:apply-templates select="text()" mode="milstd"/>
        </xs:element>
    </xsl:template>
    <xsl:template match="xs:element[@ref = 'VersionOfMessageTextFormatText']" mode="milstd">
        <xs:element name="VersionOfMessageTextFormatText" type="VersionOfMessageTextFormatTextType">
            <xsl:apply-templates select="@*[not(name() = 'ref')]" mode="milstd"/>
            <xsl:apply-templates select="*" mode="milstd"/>
            <xsl:apply-templates select="text()" mode="milstd"/>
        </xs:element>
    </xsl:template>
    <xsl:template match="xs:attributeGroup[@ref = 'structures:SimpleObjectAttributeGroup']" mode="milstd"/>
    <xsl:template match="xs:schema/xs:import" mode="milstd"/>
    <xsl:template match="xs:schema/xs:element[@abstract]" mode="milstd"/>
    <xsl:template match="*[contains(@ref, 'AugmentationPoint')]" mode="milstd"/>
    <xsl:template match="@abstract" mode="milstd"/>
    <xsl:template name="ExtractMessageSchema">
        <xsl:param name="message"/>
        <xsl:param name="outdir"/>
        <xsl:variable name="msgid" select="$MILSTDMTF/*[@name = $message/@type]/xs:annotation/xs:appinfo/*:Msg/@mtfid"/>
        <xsl:variable name="mid" select="translate($msgid, ' .:()', '')"/>
        <!--<xsl:variable name="schtron">
            <xsl:value-of
                select="concat($lt, '?xml-model', ' href=', $q, '../../../Baseline_Schema/MTF_Schema_Tests/', $mid, '.sch', $q, ' type=', $q, 'application/xml', $q, ' schematypens=', $q, 'http://purl.oclc.org/dsdl/schematron', $q, '?', $gt)"
            />
        </xsl:variable>-->
        <xsl:result-document href="{$outdir}/{concat($mid,'.xsd')}">
            <!--<xsl:text>&#10;</xsl:text>
            <xsl:value-of select="$schtron" disable-output-escaping="yes"/>
            <xsl:text>&#10;</xsl:text>-->
            <xs:schema xmlns="urn:mtf:mil:6040b:niem:mtf" 
                xmlns:ism="urn:us:gov:ic:ism" 
                xmlns:mtfappinfo="urn:mtf:mil:6040b:appinfo" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                targetNamespace="urn:mtf:mil:6040b:niem:mtf" attributeFormDefault="unqualified" version="1.0">
                <xs:import namespace="urn:us:gov:ic:ism" schemaLocation="../ext/ic-xml/ic-ism.xsd"/>
                <xs:import namespace="urn:mtf:mil:6040b:appinfo" schemaLocation="../mtfappinfo.xsd"/>
                <xs:annotation>
                    <xs:documentation>
                        <xsl:value-of select="concat($message/xs:annotation/xs:appinfo/*:Msg/@mtfname, ' MESSAGE SCHEMA')"/>
                    </xs:documentation>
                    <xs:appinfo>
                        <mtfappinfo:Msg mtfname="{$message/xs:annotation/xs:appinfo/*:Msg/@mtfname}" mtfid="{$msgid}"/>
                    </xs:appinfo>
                </xs:annotation>
                <xsl:copy-of select="$message"/>
                <xsl:copy-of select="$MILSTDMTF/xs:complexType[@name = $message/@type]"/>
                <xsl:variable name="all">
                    <xsl:for-each select="$MILSTDMTF/*[@name = $message/@type]//*[@ref | @base | @type]">
                        <xsl:variable name="n" select="@ref | @base | @type"/>
                        <xsl:call-template name="iterateNode">
                            <xsl:with-param name="node" select="$MILSTDMTF/*[@name = $n]"/>
                            <xsl:with-param name="iteration" select="18"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:for-each select="$all/xs:complexType[not(@name = $message/@type)]">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:if test="count(preceding-sibling::xs:complexType[@name = $n]) = 0">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$all/xs:simpleType">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:if test="count(preceding-sibling::xs:simpleType[@name = $n]) = 0">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$all/xs:element[not(@name = $message/@name)]">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:if test="count(preceding-sibling::xs:element[@name = $n]) = 0">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
            </xs:schema>
        </xsl:result-document>
    </xsl:template>
    <xsl:template name="iterateNode">
        <xsl:param name="node"/>
        <xsl:param name="iteration"/>
        <xsl:copy-of select="$node"/>
        <xsl:if test="$iteration &gt; 0">
            <xsl:for-each select="$node//@*[name() = 'ref' or name() = 'type' or name() = 'base'][not(. = $node/@name)]">
                <xsl:variable name="n">
                    <xsl:value-of select="."/>
                </xsl:variable>
                <xsl:call-template name="iterateNode">
                    <xsl:with-param name="node" select="$MILSTDMTF/*[@name = $n]"/>
                    <xsl:with-param name="iteration" select="number($iteration - 1)"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
