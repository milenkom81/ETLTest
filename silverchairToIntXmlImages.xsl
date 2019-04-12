<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xlink="http://www.w3.org/1999/xlink"
	exclude-result-prefixes="xs xsl">
	
	<xsl:strip-space elements="*" />

	
	<xsl:template match="body" mode="images">
		<xsl:for-each select=".//inline-graphic">
			<xsl:variable name="imagesFileName" select="concat($baseFileName, '_image_', substring-before(@xlink:href, '.'), '.xml')"/>
			<xsl:result-document href="{$imagesFileName}" method="xml" omit-xml-declaration="no" encoding="UTF-8" indent="yes" doctype-public="" doctype-system="">
			<xsl:variable name="fileName" select="@xlink:href"/>	
				<xsl:element name="records">
					<xsl:element name="record">
						<xsl:attribute name="file">
							<xsl:value-of select="$imagesFileName"/>
						</xsl:attribute>
						<xsl:element name="assetInfo">
							<xsl:element name="ofType">
								<xsl:element name="type">
									<xsl:element name="image"/>
								</xsl:element>
							</xsl:element>
							<xsl:element name="wkmrid">
								<xsl:value-of select="$imagesFileName"/>
							</xsl:element>
							<xsl:element name="assetId">
								<xsl:value-of select="substring-before($imagesFileName, '.')"/>
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
									<xsl:value-of select="@xlink:href"/>
								</xsl:element>
							</xsl:element>						
						</xsl:element>
						<xsl:element name="content-ofType-image">
							<xsl:element name="fileLink">
								<xsl:value-of select="@xlink:href"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>				
				</xsl:element>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="text()" mode="images">
		<xsl:copy/>
	</xsl:template>
	
	<!-- Identity Template -->
	<xsl:template match="@* | * | comment() | processing-instruction()" mode="images">
		<xsl:apply-templates select="@* | node()" mode="images"/>
	</xsl:template>
	
	
	 
</xsl:stylesheet>