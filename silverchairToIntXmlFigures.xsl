<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xlink="http://www.w3.org/1999/xlink"
	exclude-result-prefixes="xs xsl">
	
	<xsl:strip-space elements="*" />

	
	<xsl:template match="body" mode="figures">
		<xsl:for-each select=".//fig">
			<xsl:variable name="figId"><xsl:number/></xsl:variable>
			<xsl:variable name="figFileName" select="concat($baseFileName, '_fig_', $figId, '.xml')"/>
			<xsl:result-document href="{$figFileName}" method="xml" omit-xml-declaration="no" encoding="UTF-8" indent="yes" doctype-public="" doctype-system="">	
				<xsl:element name="records">
					<xsl:element name="record">
						<xsl:attribute name="file">
							<xsl:value-of select="$figFileName"/>
						</xsl:attribute>
						<xsl:element name="assetInfo">
							<xsl:element name="ofType">
								<xsl:element name="type">
									<xsl:element name="image"/>
								</xsl:element>
							</xsl:element>
							<xsl:element name="wkmrid">
								<xsl:value-of select="$figFileName"/>
							</xsl:element>
							<xsl:element name="assetId">
								<xsl:value-of select="substring-before($figFileName, '.')"/>
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
							<xsl:element name="representation">
								<xsl:element name="isPrimary"/>
								<xsl:element name="wkmrid">
									<xsl:value-of select="graphic/@xlink:href"/>
								</xsl:element>
							</xsl:element>						
						</xsl:element>
						<xsl:element name="content-ofType-figure">
							<xsl:attribute name="ID">
								<xsl:value-of select="$figId"/>
							</xsl:attribute>
							<xsl:if test="@position">
								<xsl:element name="presentation">
									<xsl:element name="key">
										<xsl:value-of select="'position'"/>
									</xsl:element>
									<xsl:element name="value">
										<xsl:value-of select="@position"/>
									</xsl:element>
								</xsl:element>
							</xsl:if> 
							<xsl:apply-templates select="node()" mode="figures"/>
							<xsl:element name="content-ofType-image">
								<xsl:element name="fileLink">
									<xsl:value-of select="graphic/@xlink:href"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>				
				</xsl:element>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="fig/label" mode="figures">
		<xsl:element name="header">
			<xsl:apply-templates select="node()" mode="figures"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="caption" mode="figures">
		<xsl:element name="content-ofType-caption">
			<xsl:apply-templates select="node()" mode="figures"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="caption/title" mode="figures">
		<xsl:element name="paragraph">
			<xsl:apply-templates select="node()" mode="figures"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="caption/p" mode="figures">
		<xsl:element name="paragraph">
			<xsl:apply-templates select="node()" mode="figures"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="text()" mode="figures">
		<xsl:copy/>
	</xsl:template>
	
	<!-- Identity Template -->
	<xsl:template match="@* | * | comment() | processing-instruction()" mode="figures">
		<xsl:apply-templates select="@* | node()" mode="images"/>
	</xsl:template>
	
	
	 
</xsl:stylesheet>