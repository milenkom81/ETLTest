<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:saxon="http://saxon.sf.net/"

	exclude-result-prefixes="xs xsl saxon">
	
	<xsl:strip-space elements="*" />
	
	<xsl:template match="body" mode="tables">
		<xsl:for-each select=".//table-wrap">
			<xsl:variable name="tblId"><xsl:number count="table-wrap" level="any" format="1"/></xsl:variable>
			<xsl:variable name="tablesFileName" select="concat($baseFileName, '_table_', $tblId, '.xml')"/>
			<xsl:result-document href="{$tablesFileName}" method="xml" omit-xml-declaration="no" encoding="UTF-8" indent="yes" doctype-public="" doctype-system="" saxon:character-representation="entity" >
				<xsl:element name="records">
					<xsl:element name="record">
						<xsl:attribute name="file">
							<xsl:value-of select="$tablesFileName"/>
						</xsl:attribute>
						<xsl:element name="assetInfo">
							<xsl:element name="ofType">
								<xsl:element name="type">
									<xsl:element name="table"/>
								</xsl:element>
							</xsl:element>
							<xsl:element name="wkmrid">
								<xsl:value-of select="$tablesFileName"/>
							</xsl:element>
							<xsl:element name="assetId">
								<xsl:value-of select="substring-before($tablesFileName, '.')"/>
							</xsl:element>
							<xsl:element name="parentWkmrid">
								<xsl:element name="ofType">
									<xsl:element name="type">
										<xsl:element name="topic"/>
									</xsl:element>
								</xsl:element>
								<xsl:element name="wkmrid">
									<xsl:value-of select="concat($baseFileName, '.xml')"/>
								</xsl:element>
							</xsl:element>					
						</xsl:element>
						<xsl:element name="content-ofType-table">
							<xsl:apply-templates select="label" mode="tables"/>
							<xsl:apply-templates select="caption" mode="tables"/>
							<xsl:element name="content-ofType-table">
								<xsl:element name="xhtml">
									<xsl:element name="body" namespace="http://www.w3.org/1999/xhtml">
										<xsl:apply-templates select="table" mode="tables"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>				
				</xsl:element>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="table-wrap/label" mode="tables">
		<xsl:element name="header">
			<xsl:apply-templates select="node()" mode="tables"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="table-wrap/caption" mode="tables">
		<xsl:element name="content-ofType-caption">
			<xsl:apply-templates select="node()" mode="tables"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="table-wrap/caption/title" mode="tables">
		<xsl:element name="paragraph">
			<xsl:apply-templates select="node()" mode="tables"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="text()" mode="tables">
		<xsl:copy/>
	</xsl:template>

	<xsl:template match="@*" mode="copy-attributes">
		<xsl:copy/>
	</xsl:template>

	<xsl:template match="table | td | th | tr | th | tbody | thead" mode="tables">
	  <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
	  	    <xsl:apply-templates select="@*" mode="copy-attributes"/>
	    	<xsl:apply-templates select="* | text()" mode="tables" />
	  </xsl:element>
	</xsl:template>
	
	<!-- Identity Template -->
	<xsl:template match="@* | * | comment() | processing-instruction()" mode="tables">
		<xsl:apply-templates select="@* | node()" mode="tables"/>
	</xsl:template>
	 
</xsl:stylesheet>