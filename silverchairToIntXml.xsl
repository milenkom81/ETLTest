<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
	
	xmlns:saxon="http://saxon.sf.net/"
	
	exclude-result-prefixes="xs xsl saxon xlink">
	
	<xsl:strip-space elements="*" />

	<xsl:output method="xml" omit-xml-declaration="no" indent="yes" 
	encoding="UTF-8"
	saxon:character-representation="entity" />

	<xsl:variable name="inputFolderAndFile">
		<xsl:call-template name="getValuesBeforeAndAfterLastOccurance">
	    	<xsl:with-param name="inputString" select="string(base-uri(.))" />
	    	<xsl:with-param name="char" select="'/'" />
	  	</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="inputFolderPath" select="substring-before($inputFolderAndFile, '*')"/>	

	<xsl:variable name="inputFile" select="substring-after($inputFolderAndFile, '*')"/>	
	
	<xsl:variable name="baseFileName" select="substring-before($inputFile, '.')"/>

	

	<xsl:variable name="documentType" select="'topic'"/>
	<xsl:variable name="mediumType" select="'electronic'"/>

	<!-- Includes of XSLT Files -->
	
	<xsl:include href="utilities.xsl"/>

<!-- 	<xsl:include href="silverchairToIntXmlImages.xsl"/> -->
	<xsl:include href="silverchairToIntXmlTables.xsl"/>
	<xsl:include href="silverchairToIntXmlFormulas.xsl"/>
	<xsl:include href="silverchairToIntXmlFigures.xsl"/>

	<!-- Identity Template - Process children -->
	<xsl:template match="/">
		<xsl:apply-templates select="node()" />
	</xsl:template>

		<!-- Drop Template -->
	<xsl:template match="@* | * | comment() | processing-instruction()">
		<xsl:apply-templates select="@* | node()" />
	</xsl:template>

	<xsl:template match="@* | * | comment() | processing-instruction()" mode="insert endMeta refArticle refVolume refSource">
		<xsl:apply-templates select="@* | node()" />
	</xsl:template>

	<xsl:template match="book-part-id | subj-group | book-id | book-title | pub-date | pub-history"/>

	<xsl:template match="mixed-citation[@publication-type='book']" mode="refVolume refSource"/>

	<xsl:template match="text()">
		<xsl:copy/>
	</xsl:template>

	<xsl:template match="text()" mode="insert endMeta refArticle refVolume refSource">
	</xsl:template>

	<!-- Wrapper -->

	<xsl:template match="book-part-wrapper">
		<xsl:element name="records">
			<xsl:element name="record">
				<xsl:attribute name="file">
					<xsl:value-of select="$inputFile"/>
				</xsl:attribute>
				<xsl:element name="assetInfo">
					<xsl:element name="ofType">
						<xsl:element name="type">
							<xsl:element name="topic"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="wkmrid">
						<xsl:value-of select="$inputFile"/>
					</xsl:element>
					<xsl:element name="assetId">
						<xsl:value-of select="substring-before($inputFile, '.')"/>
					</xsl:element>
					<xsl:element name="status">
						<xsl:element name="active"/>
					</xsl:element>
					<xsl:element name="assetSchemaVersion">
						<xsl:text>06.01.02</xsl:text>
					</xsl:element>
					<!-- <xsl:element name="representation">
						<xsl:element name="wkmrid">
							<xsl:value-of select="concat(substring-before($inputFile, '.'), '.html')"/>
						</xsl:element>
						<xsl:element name="qualifier">
							<xsl:text>HTML5</xsl:text>
						</xsl:element>
						<xsl:element name="isPrimary"/>
					</xsl:element> -->
				</xsl:element>
				<xsl:apply-templates select="node()" />
				<xsl:apply-templates select="//subj-group[@subj-group-type='category-gen-category']" mode="endMeta"/>
				<xsl:apply-templates select="//subj-group[@subj-group-type='category-print-pub']" mode="endMeta"/>
				<xsl:apply-templates select="//p[ancestor::sec[parent::sec[@sec-type='CODES']]]" mode="endMeta"/>
				<xsl:apply-templates select="//ref-list | //sec[@sec-type='ADDITIONAL-READING']/list" mode="endMeta"/>
			<!-- 	<xsl:apply-templates select="//body" mode="images"/> -->
				<xsl:apply-templates select="//body" mode="tables"/>
				<xsl:apply-templates select="//body" mode="formulas"/>
				<xsl:apply-templates select="//body" mode="figures"/>
			</xsl:element>		
		</xsl:element>
	</xsl:template>

<!-- 	document meta -->

	<xsl:template match="book-part-meta">
		<xsl:element name="metadata">
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="{$documentType}"/>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="../body/sec[child::title='Copyright']" mode="insert" />
			<xsl:if test="pub-date/year and not(../body/sec[child::title='Copyright'])">
					<xsl:element name="copyright">
						<xsl:element name="input-data">
							<xsl:value-of select="pub-date/year"/>
						</xsl:element>
						<xsl:element name="year">
							<xsl:value-of select="pub-date/year"/>
						</xsl:element>
					</xsl:element>
			</xsl:if>
			<xsl:apply-templates select="//book-meta/book-title-group/book-title" mode="insert" />
			<xsl:apply-templates select="pub-date" mode="insert"/>
			<xsl:apply-templates select="title-group" />
			<xsl:apply-templates select="../body/sec[child::title='Consumer Information Use and Disclaimer']" mode="insert" />
      		<xsl:element name="externalId">
				<xsl:element name="value">
					<xsl:value-of select="substring-before($inputFile, '.')"/>
				</xsl:element>
				<xsl:element name="ofType">
					<xsl:element name="type">
						<xsl:element name="pci-doc-id"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="contrib-group/contrib" />
			<xsl:apply-templates select="contrib-group" />
			<xsl:element name="publisher">
				<xsl:element name="organization">
					<xsl:element name="ofType">
						<xsl:element name="type">
							<xsl:element name="publisher"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="orgName">
						<xsl:text>Wolters Kluwer</xsl:text>
					</xsl:element>
				</xsl:element>				
			</xsl:element>
		</xsl:element>	
		<xsl:apply-templates select="..//mixed-citation" mode="refArticle" />
		<xsl:apply-templates select="..//mixed-citation" mode="refVolume" />
		<xsl:apply-templates select="..//mixed-citation" mode="refSource" />
	</xsl:template>

	<xsl:template match="book-title" mode="insert">
		<xsl:element name="extContentType">
      		<xsl:element name="value">
      			<xsl:value-of select="if(substring(., 1, 4)='5MC ') then substring-after(., '5MC ') else node()"/>
      		</xsl:element>
      		<xsl:element name="ofType">
      			<xsl:element name="type">
      				<xsl:element name="category"/>
      			</xsl:element>
      		</xsl:element>
      	</xsl:element>
	</xsl:template>

	<xsl:template match="pub-date" mode="insert">
		<xsl:element name="pubHist">
			<xsl:element name="medium">
				<xsl:element name="type">
					<xsl:element name="{$mediumType}"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="publicationDate">
				<xsl:element name="date">
					<xsl:apply-templates select="year" mode="insert" />
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="year" mode="insert">
		<xsl:element name="year">
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>

	<xsl:template match="title-group">
		<xsl:element name="title">
			<xsl:apply-templates select="node()"/>
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="title"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="title-group/title">
		<xsl:element name="value">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="contrib-group">
		<xsl:element name="contributorGroup">
			<xsl:attribute name="id"><xsl:value-of select="'CG-'"/><xsl:number/></xsl:attribute>
			<xsl:element name="organization">
				<xsl:element name="ofType">
					<xsl:element name="type">
						<xsl:element name="contributor-group"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="contrib">
		<xsl:variable name="contribNum" select="count(../../contrib-group)"/>
		<xsl:element name="contributor">
			<xsl:element name="xref">
				<xsl:attribute name="refId">
					<xsl:value-of select="concat('CG-', $contribNum)"/>
				</xsl:attribute>
				<xsl:element name="ofType">
					<xsl:element name="type">
						<xsl:element name="contributor-group"/>
					</xsl:element>
				</xsl:element>				
			</xsl:element>
			<xsl:apply-templates select="node()"/>
			<xsl:apply-templates select="@*" mode="process-attributes"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="contrib/name">
		<xsl:element name="personName">
			<xsl:apply-templates select="@*" mode="process-attributes"/>
			<xsl:apply-templates select="name"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="contrib/name/given-names">
		<xsl:element name="firstName">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="contrib/name/surname">
		<xsl:element name="lastName">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="degrees">
		<xsl:element name="degree">
			<xsl:element name="title">
				<xsl:apply-templates select="node()"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mixed-citation[not(@publication-type='book')]" mode="refArticle">
		<xsl:element name="metadata">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('metadata_FROM_ref_ID_', generate-id(.), '_ref_FLOATING')"/>
			</xsl:attribute>			
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="article"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="title">
				<xsl:element name="value">
					<xsl:value-of select="article-title"/>
				</xsl:element>
				<xsl:element name="ofType">
					<xsl:element name="type">
						<xsl:element name="title"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select=".//name" mode="refArticle"/>
			<xsl:apply-templates select="person-group" mode="refArticle"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mixed-citation[@publication-type='book']" mode="refArticle">
		<xsl:element name="metadata">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('metadata_FROM_ref_ID_', generate-id(.), '_ref_FLOATING')"/>
			</xsl:attribute>
			<xsl:apply-templates select="edition" mode="refArticle"/>		
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="book"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="pagination">
				<xsl:apply-templates select="fpage" mode="refSource"/>
				<xsl:apply-templates select="lpage" mode="refSource"/>		
			</xsl:element>
			<xsl:element name="title">
				<xsl:element name="value">
					<xsl:value-of select="article-title or part-title"/>
				</xsl:element>
				<xsl:element name="ofType">
					<xsl:element name="type">
						<xsl:element name="title"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select=".//name" mode="refArticle"/>
			<xsl:apply-templates select="person-group" mode="refArticle"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mixed-citation[not(@publication-type='book')]" mode="refVolume">
		<xsl:element name="metadata">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('metadata_FROM_ref_ID_', generate-id(.), '_ref_FLOATING')"/>
			</xsl:attribute>
			<xsl:apply-templates select="issue" mode="refVolume"/>
			<xsl:apply-templates select="volume" mode="refVolume"/>		
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="issue"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mixed-citation[not(@publication-type='book')]" mode="refSource">
		<xsl:element name="metadata">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('metadata_FROM_ref_ID_', generate-id(.), '_ref_FLOATING')"/>
			</xsl:attribute>	
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="journal"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="pagination">
				<xsl:apply-templates select="fpage" mode="refSource"/>
				<xsl:apply-templates select="lpage" mode="refSource"/>		
			</xsl:element>
			<xsl:element name="pubHist">
				<xsl:element name="publicationDate">
					<xsl:element name="date">
						<xsl:apply-templates select="year" mode="refSource"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="source" mode="refSource"/>
			<xsl:apply-templates select="pub-id" mode="refSource"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="person-group" mode="refArticle">
		<xsl:element name="contributorGroup">
			<xsl:attribute name="id"><xsl:value-of select="'PG-'"/><xsl:number level="any"/></xsl:attribute>
			<xsl:apply-templates select="@person-group-type" mode="process-attributes"/>
			<xsl:element name="text-format">
				<xsl:element name="ofType">
					<xsl:element name="type">
						<xsl:element name="input-data"/>
					</xsl:element>
				</xsl:element>
				<xsl:element name="value">
					<xsl:apply-templates select="*"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="organization">
				<xsl:element name="ofType">
					<xsl:element name="type">
						<xsl:choose>
							<xsl:when test="collab">
								<xsl:element name="collaboration"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="person-group"/>
							</xsl:otherwise>
						</xsl:choose>					
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="name[ancestor::mixed-citation]" mode="refArticle">
		<xsl:variable name="groupType" select="../@person-group-type" />
		<xsl:element name="contributor">
			<xsl:element name="xref">
				<xsl:attribute name="refId">
					<xsl:value-of select="'PG-'"/><xsl:number select=".." level="any"/>
				</xsl:attribute>
				<xsl:element name="ofType">
					<xsl:element name="type">
						<xsl:element name="person-group"/>
					</xsl:element>
				</xsl:element>				
			</xsl:element>
			<xsl:element name="personName">
				<xsl:apply-templates select="given-names" mode="refArticle"/>
				<xsl:apply-templates select="surname" mode="refArticle"/>
				<xsl:apply-templates select="suffix" mode="refArticle"/>
			</xsl:element>
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="{$groupType}"/>
				</xsl:element>
			</xsl:element>
		<!-- 	<xsl:apply-templates select="../@person-group-type" mode="process-attributes"/> -->
		</xsl:element>
	</xsl:template>

	<xsl:template match="surname[ancestor::mixed-citation]" mode="refArticle">
		<xsl:element name="lastName">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="given-names[ancestor::mixed-citation]" mode="refArticle">
		<xsl:element name="firstName">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="suffix[ancestor::mixed-citation]" mode="refArticle">
		<xsl:element name="suffix">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="article-title | part-title">
		<xsl:element name="tag-ofType-title">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mixed-citation/year">
		<xsl:element name="tag-ofType-year">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="pub-id[ancestor::mixed-citation]" mode="refSource">
		<xsl:variable name="pubType" select="@pub-id-type"/>
		<xsl:element name="externalId">
			<xsl:element name="value">
				<xsl:apply-templates select="node()"/>
			</xsl:element>
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="{$pubType}"/>
				</xsl:element>			
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mixed-citation/year" mode="refSource">
		<xsl:element name="year">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="source">
		<xsl:element name="tag-ofType-journal-title">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="edition">
		<xsl:element name="tag-ofType-edition">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="edition" mode="refArticle">
		<xsl:element name="edition">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="publisher-loc">
		<xsl:element name="tag-ofType-location">
			<xsl:element name="auxiliaryOfTypeRef">
				<xsl:element name="type">
					<xsl:element name="publisher"/>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="publisher-name">
		<xsl:element name="tag-ofType-name">
			<xsl:element name="auxiliaryOfTypeRef">
				<xsl:element name="type">
					<xsl:element name="publisher"/>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="source" mode="refSource">
		<xsl:element name="title">
			<xsl:element name="value">
				<xsl:apply-templates select="node()"/>
			</xsl:element>
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="title"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

<!-- 	full text -->

	<xsl:template match="body">
		<xsl:element name="full-text-content">
			<xsl:element name="content-ofType-body-matter">
				<xsl:apply-templates select="node()"/>
		<!-- 		<xsl:apply-templates select="//inline-graphic[parent::label]" mode="insert"/> -->
				<xsl:apply-templates select="//disp-formula[child::graphic]" mode="insert"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="sec">
		<xsl:element name="content-ofType-section">
			<xsl:apply-templates select="@*" mode="process-attributes"/>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="sec/title | boxed-text/caption/title">
		<xsl:element name="header">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="list[not(parent::sec[@sec-type='ADDITIONAL-READING'])]">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@*" mode="process-attributes"/>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="boxed-text">
		<xsl:element name="content-ofType-boxed-text">
			<xsl:apply-templates select="@*" mode="process-attributes"/>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="caption">
		<xsl:element name="content-ofType-caption">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="p[not(ancestor::sec[@sec-type='ADDITIONAL-READING']) and not(ancestor::sec[@sec-type='CODES'])]">
		<xsl:element name="paragraph">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

<!-- 	<xsl:template match="inline-graphic[parent::label]">
		<xsl:variable name="iconName" select="lower-case(../../@sec-type)"/>
		<xsl:variable name="imagesFileName" select="concat($baseFileName, '_image_', substring-before(@xlink:href, '.'), '.xml')"/>
		<xsl:variable name="imgId"><xsl:number count="inline-graphic" level="any" format="1"/></xsl:variable>
		<xsl:element name="asset-reference">
			<xsl:attribute name="refId">
				<xsl:value-of select="$imagesFileName"/>
			</xsl:attribute>
			<xsl:attribute name="ofType">
				<xsl:value-of select="'image'"/>
			</xsl:attribute>
			<xsl:attribute name="defaultRepresentationWkmrid">
				<xsl:value-of select="@xlink:href"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template> -->

	<xsl:template match="disp-formula[child::graphic]">
		<xsl:variable name="mathId"><xsl:number count="disp-formula" level="any" format="1"/></xsl:variable>
		<xsl:variable name="mathFileName" select="concat($baseFileName, '_math_', $mathId, '.xml')"/>
		<xsl:element name="asset-reference">
			<xsl:attribute name="refId">
				<xsl:value-of select="$mathFileName"/>
			</xsl:attribute>
			<xsl:attribute name="ofType">
				<xsl:value-of select="'math'"/>
			</xsl:attribute>
			<xsl:attribute name="defaultRepresentationWkmrid">
				<xsl:value-of select="graphic/@xlink:href"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

<!-- 	<xsl:template match="inline-graphic[parent::label]" mode="insert">
		<xsl:variable name="iconName" select="lower-case(../../@sec-type)"/>
		<xsl:variable name="imagesFileName" select="concat($baseFileName, '_image_', substring-before(@xlink:href, '.'), '.xml')"/>
		<xsl:variable name="imgId"><xsl:number count="inline-graphic" level="any" format="1"/></xsl:variable>
		<xsl:element name="childAssetMap">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('I1-', $imgId)"/>
			</xsl:attribute>
			<xsl:attribute name="wkmrid">
				<xsl:value-of select="$imagesFileName"/>
			</xsl:attribute>
			<xsl:attribute name="ofType">
				<xsl:value-of select="'image'"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>
 -->
	<xsl:template match="disp-formula[child::graphic]" mode="insert">
		<xsl:variable name="mathId"><xsl:number count="disp-formula" level="any" format="1"/></xsl:variable>
		<xsl:variable name="mathFileName" select="concat($baseFileName, '_math_', $mathId, '.xml')"/>
		<xsl:element name="childAssetMap">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('M1-', $mathId)"/>
			</xsl:attribute>
			<xsl:attribute name="wkmrid">
				<xsl:value-of select="$mathFileName"/>
			</xsl:attribute>
			<xsl:attribute name="ofType">
				<xsl:value-of select="'math'"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="p[ancestor::sec[@sec-type='CODES']]">
		<xsl:variable name="codeType">
		<xsl:choose>
			<xsl:when test="ancestor::sec[not(@sec-type='CODES')]/@sec-type='ICD9'">
				<xsl:value-of select="'tag-ofType-icd09-code'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('tag-ofType-', lower-case(ancestor::sec[not(@sec-type='CODES')]/@sec-type), '-code')"/>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		<xsl:element name="paragraph">
			<xsl:element name="{$codeType}">
				<xsl:value-of select="substring-before(., ' ')"/>
			</xsl:element>
			<xsl:value-of select="concat(' ', substring-after(., ' '))"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="p/italic | title/italic">
		<xsl:element name="emphasis-withStyle-italic">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="bold">
		<xsl:element name="emphasis-withStyle-bold">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="sc">
		<xsl:element name="emphasis-withStyle-small-caps">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="sub">
		<xsl:element name="emphasis-withStyle-subscript">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="sup">
		<xsl:element name="emphasis-withStyle-superscript">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="xref[@ref-type='bibr']">
		<xsl:element name="xref-ofType-citation">
			<xsl:attribute name="refId">
				<xsl:value-of select="concat('R1-', .)"/> <!-- not a good way, but no better information in the input -->
			</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<!-- refs as part of full text -->

	<xsl:template match="ref-list | sec[@sec-type='ADDITIONAL-READING']/list">
		<xsl:element name="list">
			<xsl:element name="ofType">
				<xsl:element name="type">
<!-- 					<xsl:element name="LOOKUP"> -->
						<xsl:element name="references"/>
					<!-- 		<xsl:value-of select="'references'"/>
						</xsl:element> -->
			<!-- 		</xsl:element> -->
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="list-item">
		<xsl:element name="listItem">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ref">
		<xsl:variable name="ref-Id"><xsl:number/></xsl:variable>
		<xsl:element name="listItem">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('R1-', $ref-Id)"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ext-link[not(@ext-link-type='ebm')]">
		<xsl:variable name="linkType" select="@ext-link-type"/>
		<xsl:element name="externalLinkRef">
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="simple"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="format">
				<xsl:element name="{$linkType}"/>
			</xsl:element>
			<xsl:element name="href">
				<xsl:value-of select="@xlink:href"/>
			</xsl:element>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ext-link[@ext-link-type='ebm']">
		<xsl:element name="externalLink">
			<xsl:apply-templates select="@*" mode="process-attributes"/>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mixed-citation">
		<xsl:element name="xref-ofType-citation">
			<xsl:attribute name="refId">
				<xsl:value-of select="concat('citation_FROM_ref_ID_', generate-id(.), '_citation_FLOATING')"/>
			</xsl:attribute>
			<xsl:element name="tag-ofType-display-citation">
				<xsl:value-of select=".//text()"/>
			</xsl:element>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="pub-id[ancestor::mixed-citation]">
		<xsl:element name="tag-ofType-pub-id">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="collab[ancestor::mixed-citation]">
		<xsl:element name="tag-ofType-collaboration">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="name[ancestor::mixed-citation]">
		<xsl:element name="tag-ofType-name">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="surname[ancestor::mixed-citation]">
		<xsl:element name="tag-ofType-last-name">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="given-names[ancestor::mixed-citation]">
		<xsl:element name="tag-ofType-first-name">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="suffix[ancestor::mixed-citation]">
		<xsl:element name="tag-ofType-suffix">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="issue">
		<xsl:element name="tag-ofType-issue">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="volume">
		<xsl:element name="tag-ofType-volume">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="issue" mode="refVolume">
		<xsl:element name="issue">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="volume" mode="refVolume">
		<xsl:element name="volume">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="fpage">
		<xsl:element name="tag-ofType-first-page">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="lpage">
		<xsl:element name="tag-ofType-last-page">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="fpage" mode="refSource">
		<xsl:element name="pageRange">
		<xsl:element name="firstPage">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="lpage" mode="refSource">
		<xsl:element name="pageRange">
		<xsl:element name="lastPage">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
		</xsl:element>
	</xsl:template>


<!-- end meta -->

	<xsl:template match="p[ancestor::sec[@sec-type='CODES']]" mode="endMeta">
		<xsl:variable name="codeType" select="upper-case(substring-after(ancestor::sec[not(@sec-type='CODES')]/@id, 'codes_'))"/>
		<xsl:element name="l1d">
			<xsl:element name="descriptor">
				<xsl:element name="term">
					<xsl:apply-templates select="node()"/>
				</xsl:element>
				<xsl:element name="externalId">
					<xsl:element name="value">
						<xsl:value-of select="substring-before(., ' ')"/>
					</xsl:element>
					<xsl:element name="ofType">
						<xsl:element name="type">
							<xsl:element name="other">
								<xsl:element name="typeForOther">
									<xsl:value-of select="$codeType"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="subj-group[@subj-group-type='category-gen-category']" mode="endMeta">
		<xsl:element name="l1d">
			<xsl:element name="descriptor">
				<xsl:element name="descriptorType">
					<xsl:element name="category"/>
				</xsl:element>
				<xsl:element name="term">
					<xsl:value-of select="subject"/>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="..//subj-group[@subj-group-type='category-specialty']" mode="endMeta" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="subj-group[@subj-group-type='category-specialty']" mode="endMeta">
		<xsl:element name="l2d">
			<xsl:element name="descriptor">
				<xsl:element name="descriptorType">
					<xsl:element name="category"/>
				</xsl:element>
				<xsl:element name="term">
					<xsl:value-of select="subject"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ref-list" mode="endMeta">
		<xsl:element name="cSet1">
			<xsl:element name="title">
				<xsl:element name="value">
					<xsl:value-of select="../title"/>
				</xsl:element>
				<xsl:element name="ofType">
					<xsl:element name="type">
						<xsl:element name="title"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="ref/mixed-citation" mode="endMeta"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="sec[@sec-type='ADDITIONAL-READING']/list" mode="endMeta">
		<xsl:element name="cSet1">
			<xsl:element name="title">
				<xsl:element name="value">
					<xsl:value-of select="../title"/>
				</xsl:element>
				<xsl:element name="ofType">
					<xsl:element name="type">
						<xsl:element name="title"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="list-item/p/mixed-citation" mode="endMeta"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mixed-citation" mode="endMeta">
		<xsl:variable name="referenceType" select="@publication-type"/>
		<xsl:element name="citation">
			<xsl:element name="id">
				<xsl:element name="value">
					<xsl:value-of select="concat('citation_FROM_ref_ID_', generate-id(.), '_citation_FLOATING')"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="input-data">
				<xsl:apply-templates select=".//text()"/>
			</xsl:element>
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="{$referenceType}"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="inline-metadata-reference">
				<xsl:attribute  name="refId">
					<xsl:value-of select="concat('metadata_FROM_ref_ID_', generate-id(.), '_ref_FLOATING')"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>


	<!-- lab tests -->

	<xsl:template match="xref[@ref-type='table']">
		<xsl:variable name="tblId"><xsl:number/></xsl:variable>
		<xsl:variable name="tablesFileName" select="concat($baseFileName, '_table_', $tblId, '.xml')"/>
		<xsl:element name="xref-ofType-child-asset-map">
			<xsl:attribute name="refId">
				<xsl:value-of select="$tablesFileName"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
		<xsl:element name="childAssetMap">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('T1-', $tblId)"/>
			</xsl:attribute>
			<xsl:attribute name="wkmrid">
				<xsl:value-of select="$tablesFileName"/>
			</xsl:attribute>
			<xsl:attribute name="ofType"><xsl:value-of select="'table'"/></xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="table-wrap">
		<xsl:variable name="tblId"><xsl:number/></xsl:variable>
		<xsl:variable name="tablesFileName" select="concat($baseFileName, '_table_', $tblId, '.xml')"/>
		<xsl:element name="asset-reference">
			<xsl:attribute name="refId">
				<xsl:value-of select="$tablesFileName"/>
			</xsl:attribute>
			<xsl:attribute name="ofType">
				<xsl:value-of select="'table'"/>
			</xsl:attribute>
		<!-- 	<xsl:apply-templates select="node()"/> -->
		</xsl:element>
	</xsl:template>

	<xsl:template match="xref[@ref-type='fig']">
		<xsl:variable name="figId"><xsl:number/></xsl:variable>
		<xsl:variable name="figFileName" select="concat($baseFileName, '_fig_', $figId, '.xml')"/>
		<xsl:element name="xref-ofType-child-asset-map">
			<xsl:attribute name="refId">
				<xsl:value-of select="$figFileName"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
		<xsl:element name="childAssetMap">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('F1-', $figId)"/>
			</xsl:attribute>
			<xsl:attribute name="wkmrid">
				<xsl:value-of select="$figFileName"/>
			</xsl:attribute>
			<xsl:attribute name="ofType"><xsl:value-of select="'figure'"/></xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="fig">
		<xsl:variable name="figId"><xsl:number/></xsl:variable>
		<xsl:variable name="figFileName" select="concat($baseFileName, '_fig_', $figId, '.xml')"/>
		<xsl:element name="asset-reference">
			<xsl:attribute name="refId">
				<xsl:value-of select="$figFileName"/>
			</xsl:attribute>
			<xsl:attribute name="ofType">
				<xsl:value-of select="'figure'"/>
			</xsl:attribute>
		<!-- 	<xsl:apply-templates select="node()"/> -->
		</xsl:element>
	</xsl:template>

	<xsl:template match="subj-group[@subj-group-type='category-print-pub']" mode="endMeta">
		<xsl:element name="l1d">
			<xsl:element name="descriptor">
				<xsl:element name="descriptorType">
					<xsl:element name="category"/>
				</xsl:element>
				<xsl:element name="term">
					<xsl:value-of select="subject"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- patient handouts -->


	<xsl:template match="sec[child::title='Copyright']" mode="insert">
		<xsl:element name="copyright">
			<xsl:element name="input-data">
				<xsl:value-of select="p"/>
			</xsl:element>
			<xsl:element name="year">
				<xsl:value-of select="substring(substring-after(p, 'Copyright © '), 1, 4)"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="sec[child::title='Consumer Information Use and Disclaimer']" mode="insert">
		<xsl:element name="caption">
			<xsl:element name="ofType">
				<xsl:element name="type">
					<xsl:element name="disclaimer"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="captionText">
				<xsl:element name="content">
					<xsl:value-of select="p"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- Attributes -->

	<xsl:template match="@content-type | @sec-type | @disp-level | @name-style | @person-group-type" mode="process-attributes">
		<xsl:element name="property">
			<xsl:element name="key">
				<xsl:value-of select="name(.)"/>
			</xsl:element>
			<xsl:element name="value">
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="@list-type | @contrib-type " mode="process-attributes">
		<xsl:variable name="elementValue" select="."/>
		<xsl:element name="ofType">
			<xsl:element name="type">
				<xsl:element name="{$elementValue}"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="@ext-link-type[.='ebm']" mode="process-attributes">
		<xsl:variable name="elementValue" select="."/>
		<xsl:element name="ofType">
			<xsl:element name="type">
				<xsl:element name="{$elementValue}"/>
			</xsl:element>
		</xsl:element>
		<xsl:element name="format">
			<xsl:element name="file"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ext-link/@xlink:href" mode="process-attributes">
		<xsl:element name="href">
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>

	<!-- Process Attributes - Drop by Default -->

	<xsl:template match="@*"  mode="process-attributes"/>
		

</xsl:stylesheet>