<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:php="http://php.net/xsl"
                            xmlns:t="http://www.w3.org/1999/xhtml"
                			 extension-element-prefixes="php">
    
	<!-- Include various helper templates for use in generating reports - see functions.xsl for details -->
    <!--
    <xsl:include href="../functions.xsl" />
	-->
    <!-- http://stackoverflow.com/questions/586231/how-can-i-convert-a-string-to-upper-or-lower-case-with-xslt -->
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    <xsl:template match="/">
        <xsl:value-of select="translate(doc, $uppercase, $lowercase)" />
    </xsl:template>

    <xsl:template name="addSelectOption">
        <xsl:param name="id" />
        <xsl:param name="caption" />
        <option value='{id}'><xsl:value-of select="$caption"/></option>
    </xsl:template>

    <xsl:template name="generateCourseNameSelector">
        <xsl:param name="component" />
        <select id="{$component}">
            <xsl:for-each select="//t:course">
                <xsl:call-template name="addSelectOption">
                    <xsl:with-param name="id"><xsl:value-of select="@id"/></xsl:with-param>
                    <xsl:with-param name="caption"><xsl:value-of select="@caption"/></xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </select>
    </xsl:template>

    <xsl:template name="generateTitle">
        <xsl:param name="unitName" />
        <xsl:param name="userName" />
        Tense Buster <xsl:value-of select="//t:course[t:unit[translate(@caption, $uppercase, $lowercase)=$unitName]]/@caption" /> coverage for <xsl:value-of select="$userName" />
    </xsl:template>

    <xsl:template name="generateUnitNames">
        <xsl:param name="unitName" />
        <xsl:param name="id" />
        <xsl:for-each select="//t:course[t:unit[translate(@caption, $uppercase, $lowercase)=$unitName]]/t:unit">
            <tr>
                <!-- In this unit, how many exercises are there and how many have at least one score node -->
                <td><xsl:value-of select="@caption"/></td>
                <td><xsl:value-of select="count(t:exercise)"/></td>
                <td>
                    <xsl:for-each select="t:exercise">
                        <xsl:choose>
                            <xsl:when test="t:score">&#10003;</xsl:when>
                            <xsl:otherwise>- </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
	<xsl:template match="/">
		<html>
			<head>
				<!-- You need this to avoid DOM warning: DOMElement::setAttribute() [domelement.setattribute]: string is not in UTF-8 -->
				<link rel="shortcut icon" href="/Software/RM.ico" type="image/x-icon" />
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<title>Results Manager Generated Coverage Report</title>
				
				<link rel="stylesheet" type="text/css" href="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/headerFooter.css" />
				<link rel="stylesheet" type="text/css" href="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/dhtmlxgrid.css" />
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/dhtmlxcommon.js"></script>
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/dhtmlxgrid.js"></script>
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/dhtmlxgridcell.js"></script> 
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/ext/dhtmlxgrid_selection.js"></script> 
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/ext/dhtmlxgrid_nxml.js"></script> 
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/ext/dhtmlxgrid_filter.js"></script> 
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/ext/dhtmlxgrid_group.js"></script>
				<script src="../../reports/standard/dhtmlx/dhtmlxGrid/codebase/ext/dhtmlxgrid_start.js"></script>
				
				<script src="../../js/prototype-1.6.0.3.js"></script>
				
				<style>
					h1 {
						color: #055A78; 
						font-family: Tahoma, Sans-Serif;
						font-size: 14px;
						font-weight: bold;
	  					background-color: #C9DBDF;
	 					border: 1px solid; 
	 					border-color: #8D8D8D #8D8D8D #8D8D8D #8D8D8D;
						padding-left: 8px;
						padding-top: 4px;
						padding-right: 8px;
						padding-bottom: 4px;
					}
                    div {
                        font-family: Tahoma, Sans-Serif;
                        font-size: 13px;
                        line-height: 14px;
                    }
                    th {
                        text-align: left;
                    }
				</style>
			</head>
			
			<body>
                <h1>
                    <xsl:call-template name="generateTitle">
                        <xsl:with-param name="unitName"><xsl:value-of select="//unit" /></xsl:with-param>
                        <xsl:with-param name="userName"><xsl:value-of select="//user/@name" /></xsl:with-param>
                    </xsl:call-template>
                </h1>
				<div id="tableDiv">
                    <table>
                        <th width="200">Unit</th>
                        <th width="120">Exercises</th>
                        <th width="200">Coverage</th>
                        <xsl:call-template name="generateUnitNames">
                            <xsl:with-param name="unitName"><xsl:value-of select="//unit" /></xsl:with-param>
                            <xsl:with-param name="id">xxxx</xsl:with-param>
                        </xsl:call-template>
                    </table>
				</div>
				
				<br/>
			</body>
		</html>
	</xsl:template>
</xsl:transform>