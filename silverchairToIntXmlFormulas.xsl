<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:my="http://wolterskluwer.com/ns/wk-mapper/local-functions"
	exclude-result-prefixes="xs xsl">
	
	<xsl:strip-space elements="*" />

	
	<xsl:template match="body" mode="formulas">
		<xsl:for-each select=".//disp-formula">
			<xsl:variable name="mathId"><xsl:number count="disp-formula" level="any" format="1"/></xsl:variable>
			<xsl:variable name="mathFileName" select="concat($baseFileName, '_math_', $mathId, '.xml')"/>
			<xsl:result-document href="{$mathFileName}" method="xml" omit-xml-declaration="no" encoding="UTF-8" indent="yes" doctype-public="" doctype-system="">
				<xsl:element name="records">
					<xsl:element name="record">
						<xsl:attribute name="file">
							<xsl:value-of select="$mathFileName"/>
						</xsl:attribute>
						<xsl:element name="assetInfo">
							<xsl:element name="ofType">
								<xsl:element name="type">
									<xsl:element name="my:math">
										<xsl:namespace name="my" select="'http://wolterskluwer.com/ns/wk-mapper/local-functions'"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="wkmrid">
								<xsl:value-of select="$mathFileName"/>
							</xsl:element>
							<xsl:element name="assetId">
								<xsl:value-of select="substring-before($mathFileName, '.')"/>
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
						<xsl:element name="content-ofType-image">
							<xsl:element name="fileLink">
								<xsl:value-of select="graphic/@xlink:href"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>				
				</xsl:element>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="text()" mode="formulas">
		<xsl:copy/>
	</xsl:template>
	
	<!-- Identity Template -->
	<xsl:template match="@* | * | comment() | processing-instruction()" mode="formulas">
		<xsl:apply-templates select="@* | node()" mode="formulas"/>
	</xsl:template>
	 
</xsl:stylesheet>