<!--- ------------------------------------------------------------------------- ----
	
	File:		XSL_Main.cfm
	Author:		Oscar Arevalo
	Desc:		This template is responsible for generating the XSL document
				that transforms the report data in XML format into the actual
				report HTML output.
				
	Update History:
				11/2/2006 - Oscar Arevalo
				Apply HTTP headers to avoid caching only when report is not
				rendered server-side.

	Copyright: 2004-2006 CFEmpire Corp.
	
	THIS FILE CAN NOT BE DISTRIBUTED WITHOUT THE EXPRESS CONSENT OF CFEMPIRE CORP.

----- ---------------------------------------------------------------------//// --->

<cfsetting showdebugoutput="no" enablecfoutputonly="yes">

<cfsilent>
	<cfscript>
		ReportMode = variables.oReportRenderBean.getReportMode();
		ExportTo = variables.oReportRenderBean.getExportTo();
		ScreenWidth = variables.oReportRenderBean.getScreenWidth() - 25;
		ScreenHeight = variables.oReportRenderBean.getScreenHeight();
		ReportHeader = "";
		ReportFooter = "";
		JSCallBack = variables.oReportRenderBean.getJSCallBack();
		serverSide = variables.oReportRenderBean.getServerSide();
		serverName = CGI.SERVER_NAME;
		
		// get report
		oReport = variables.oReport;
		thisReport = oReport.getReport();
		
		// setup page dimensions
		PageOrientation = thisReport.Width;
		
		if(ReportMode eq "Page") {
			if(PageOrientation eq "Landscape") 
				ScreenWidth = "9.4";
			else
				ScreenWidth = "6.9";
				
			ScreenWidthUnit = "in";
		
		} else {
			ScreenWidthUnit = "px";
		}
		
		// set host name
		if(serverSide) serverName = "localhost";
		
		if(cgi.SERVER_PORT neq "" and cgi.SERVER_PORT neq "80")
			thisServer  = serverName & ":" & cgi.SERVER_PORT;
		else
			thisServer  = serverName;
	</cfscript>

	<!---- Initialize all variables--->
	<cfinclude template="XSL_Init.cfm">
</cfsilent>


<cfoutput><?xml version="1.0"?> 
<xsl:stylesheet version="1.1" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:dt="http://xsltsl.org/date-time"
		xmlns:str="http://xsltsl.org/string"
		<cfif ExportTo eq "Excel">	
		xmlns:o="urn:schemas-microsoft-com:office:office" 
		xmlns:x="urn:schemas-microsoft-com:office:excel"
		</cfif>
		<cfif ExportTo eq "Word">	
		xmlns:w="urn:schemas-microsoft-com:office:word"
		</cfif>
		>

	<xsl:import href="http://#thisServer#/WebReports/common/xsltsl-1.2.1/date-time.xsl"/>
	<xsl:import href="http://#thisServer#/WebReports/common/xsltsl-1.2.1/string.xsl"/>		
	
	<xsl:output method="html" />
	<!-- rowtag : #RowName# -->

	<!--- 
	
			Keys for grouping 
			
	--->
	<cfset tmpList = "''">
	<cfloop list="#GroupNames#" index="thisGroup">
		<xsl:key name="Group_#thisGroup#" match="#RowName#" use="concat(#ListAppend(tmpList, thisGroup)#)"/>
		<cfset tmpList = ListAppend(tmpList, thisGroup)>
	</cfloop>


	<!--- 
	
			Global Variables 
			
	--->
	<xsl:variable name="NumberOfColumns" select="#NumberOfColumns#" />
	<xsl:variable name="ReportMode" select="'#ReportMode#'" />
	<xsl:variable name="ReportTitle" select="'#XMLFormat(thisReport.Title)#'" />
	<xsl:variable name="ReportSubTitle" select="'#XMLFormat(thisReport.SubTitle)#'" />
	<xsl:variable name="ReportDate" select="'#Dateformat(Now(),"mmmm d, yyyy")#'" />
	<xsl:variable name="TotalMainLabel" select="'#TotalMainLabel# '" />
	<cfif Find("%g",TotalMainLabel)>
		<xsl:variable name="GrandTotalLabel" select="'Grand Total'" />
	<cfelse>
		<xsl:variable name="GrandTotalLabel" select="'#TotalMainLabel#'" />
	</cfif>
	<xsl:variable name="Default_MaskNumeric" select="'#Default_MaskNumeric#'" />
	<xsl:variable name="Default_MaskDate" select="'#Default_MaskDate#'" />

	<!--- 
	
			Main Template 
			
	--->
	 <xsl:template match="/">
		<xsl:call-template name="HTMLPageLayout" />
	 </xsl:template>


	<!--- 
	
			Layout Templates 
	
	--->
	<xsl:template name="HTMLPageLayout">
		<html>
			<head>
				<title>
					<xsl:value-of select="$ReportTitle" /> -
					<xsl:value-of select="$ReportSubTitle" />
				</title>

				<cfif ExportTo eq "Excel">
					<style type="text/css">
						@page {
								margin:.5in .5in .5in .5in;
								mso-footer-data:"Page #XMLFormat("&P")# of #XMLFormat("&N")#";
								mso-header-margin:.5in;
								mso-footer-margin:.2in;
								mso-page-orientation:#thisReport.Width#;
							}
					</style>

					<xsl:comment><![CDATA[[if gte mso 9]><xml>
						 <x:ExcelWorkbook>
						  <x:ExcelWorksheets>
						   <x:ExcelWorksheet>
							<x:Name>Report</x:Name>
							<x:WorksheetOptions>
							 <x:FitToPage/>
							 <x:Print>
							  <x:FitHeight>100</x:FitHeight>
							  <x:ValidPrinterInfo/>
							  <x:HorizontalResolution>600</x:HorizontalResolution>
							  <x:VerticalResolution>600</x:VerticalResolution>
							 </x:Print>
							</x:WorksheetOptions>
						   </x:ExcelWorksheet>
						  </x:ExcelWorksheets>
						 </x:ExcelWorkbook>
						</xml><![endif]]]>
					</xsl:comment>
				</cfif>
				<cfif ReportMode eq "Display">
					<script language="JavaScript" type="text/javascript" src="/WebReports/common/scripts/browser_sniff.js"></script>
					<script language="JavaScript" type="text/javascript" src="/WebReports/common/scripts/fixed_headers.js"></script>
					<script type="text/javascript">
						function wr_Init() {
							//var fxTable = new FixedTable("reportView", "header");
							if(!document.readyState) document.readyState = "complete";
							<cfif JSCallBack neq "">
								try {#JSCallBack#} catch(e) { alert("A problem ocurred while initializing the report."); }
							</cfif>
						}
						window.onload = wr_Init;
					</script>
				<cfelseif JSCallBack neq "">
					<script type="text/javascript">
						function wr_init() {
							try {#JSCallBack#} catch(e) { alert("A problem ocurred while initializing the report."); }
						}
						window.onload = wr_init;
					</script>				
				</cfif>
				
				<xsl:call-template name="CSS_Style" />
			</head>
			
			<body>
				<cfswitch expression="#ReportMode#">
					<cfcase value="Display">
						<xsl:call-template name="DisplayLayout" />
					</cfcase>
					<cfcase value="Page">
						<xsl:call-template name="PageLayout" />
					</cfcase>
					<cfcase value="Labels">
						<xsl:call-template name="LabelsLayout" />
					</cfcase>
				</cfswitch>
			</body>
		</html>
	 </xsl:template>

	<cfif ReportMode eq "Display">
		<xsl:template name="DisplayLayout">
			<div class="reportView" id="ReportSpace">
				<xsl:call-template name="ReportLayout" />
			</div>
		</xsl:template>
	</cfif>

	<cfif ReportMode eq "Page">
		<xsl:template name="PageLayout">
			<table width="100%" cellpadding="0" cellspacing="0">
				<thead>
					<cfif ReportHeader eq "">
						<tr><td class="Title"><xsl:value-of select="$ReportTitle" /></td></tr>	
						<tr><td class="SubTitle"><xsl:value-of select="$ReportSubTitle" /></td></tr>
						<tr><td class="Date">Report generated on <xsl:value-of select="$ReportDate" /></td></tr>
					<cfelse>
						<tr><td>#ReportHeader#</td></tr>
					</cfif>
				</thead>
				<tbody>
					<tr>
						<td>
							<xsl:call-template name="ReportLayout" />
						</td>
					</tr>
				</tbody>
				<tfoot class="PageFooter">
					<tr><td>#ReportFooter#</td></tr>	
				</tfoot>
			</table>
		</xsl:template>
	</cfif>

	<cfif ReportMode eq "Labels">
		<xsl:template name="LabelsLayout">
			<div class="Page">
				<xsl:for-each select="#Root#/#RowName#">
					<xsl:if test="(position() mod 30 = 1 and position() != 1)">
						<div style="page-break-after:always;"><br /></div>
					</xsl:if>
					<div class="Label">
						<cfloop from="1" to="#ListLen(ColumnNames)#" index="i">
							<xsl:call-template name="DisplayData">
								<xsl:with-param name="value" select="#ListGetAt(ColumnNames,i)#"/>
								<xsl:with-param name="datatype" select="'#LCase(ListGetAt(ColumnDataTypes,i))#'"/>
								<xsl:with-param name="mask" select="'#ListGetAt(ColumnMasks,i,"|")#'"/>
							</xsl:call-template>
							<br />
						</cfloop>
					</div>
				</xsl:for-each>
			</div>
		</xsl:template>
	</cfif>
	 
	<xsl:template name="ReportLayout">
		<table border="0" cellpadding="0" cellspacing="0" align="center" class="ViewerTable">
			<!---- Report Header --->
			<thead id="ReportHeader" class="PageHeader">
				<xsl:call-template name="DisplayColumnHeaders" />
			</thead>
			
			<!---- Report  Body --->
			<tbody id="ReportBody" valign="top">
				<tr>
					<td class="emptyCell">
						<xsl:attribute name="colspan">
							<xsl:value-of select="$NumberOfColumns" />
						</xsl:attribute>
						<a name="anchor_0"></a>
					</td>
				</tr>
				<xsl:call-template name="ReportBody" />
			</tbody>
			
			<!---- Report  Footer --->
			<tfoot id="ReportFooter">
				<cfif ListLen(TotalNames) gt 0>
					<xsl:call-template name="GrandTotal" />
				<cfelse>
					<xsl:call-template name="DisplayEmptyRow" />
				</cfif>
			</tfoot>
			
		</table>
	</xsl:template>

	<!--- 
	
			Body of the report 
			
	--->
	<xsl:template name="ReportBody">
			<cf_XSL_Group 
										Root="#Root#"
										RowName="#RowName#"
										ColumnNames="#ColumnNames#"
										ColumnWidths="#ColumnWidths#"
										ColumnDataTypes="#ColumnDataTypes#"
										ColumnMasks="#ColumnMasks#"
										ColumnHREFs="#ColumnHREFs#"
										SortNames="#SortNames#"
										SortOrder="#SortOrder#"
										SortDataTypes="#SortDataTypes#"
										GroupNames="#GroupNames#" 
										GroupTitles="#GroupTitles#"
										GroupDisplayTotals="#GroupDisplayTotals#"
										GroupDisplayContents="#GroupDisplayContents#"
										GroupDataTypes="#GroupDataTypes#"
										GroupMasks="#GroupMasks#"
										TotalNames="#TotalNames#"
										TotalLabels="#TotalLabels#"
										TotalFunctions="#TotalFunctions#"
										TotalMainLabel="#TotalMainLabel#"
										TotalMasks="#TotalMasks#">
	</xsl:template>
	 
	
	<!--- 
	
			Auxiliary Templates 
			
	---> 
	<xsl:template name="GrandTotal">
		<!---- If there is more than one total column, but there is no total for the first column and
			there is a main total label, then display the main total label on the first column ---->
		<cfset UseFirstColumnForLabel = false>
		<cfif NumberOfColumns gt 1 and TotalMainLabel neq "">
			<cfset tmpPos = ListFindNoCase(TotalNames,ListGetAt(ColumnNames,1))>
			<cfif tmpPos eq 0>
				<cfset UseFirstColumnForLabel = true>
			</cfif>
		</cfif>
		
<!--- 		<cfif Not UseFirstColumnForLabel>
			<xsl:call-template name="DisplayTotalRow">
				<xsl:with-param name="value" select="$GrandTotalLabel"/>
				<xsl:with-param name="class" select="'GroupHeader_1'"/>
			</xsl:call-template>
		</cfif> --->
		<tr>
			<cfloop from="1" to="#NumberOfColumns#" index="i">
				<cfif UseFirstColumnForLabel and i eq 1>
					<td><div class="ReportTotalCell_1"><xsl:value-of select="$GrandTotalLabel" /></div></td>
				<cfelse>
					<td class="ReportCell_#i#">
						<div class="ReportTotalCell_#i#">
							<!---TotalMainLabel contains the label for the grand total 
								but we have fixed it to Grand Total for now 21/4/2004--->
							<cfset thisColumn = ListGetAt(ColumnNames,i)>
							<cfset tmpPos = ListFindNoCase(TotalNames,thisColumn)>
							
							<cfif tmpPos gt 0>
								<cfset thisFunction = ListGetAt(TotalFunctions, tmpPos)>
								<cfset thisMask = ListGetAt(TotalMasks, tmpPos, "|")>
								<cfset thisTotal = "#LCase(thisFunction)#(#Root#/#RowName#/#thisColumn#)">
								<cfset thisLabel = ListGetAt(TotalLabels, tmpPos, "|")>
								<cfset thisLabel = Replace(thisLabel, "NOLABEL", "")>
								#thisLabel#
								<xsl:call-template name="DisplayData">
									<xsl:with-param name="value" select="#thisTotal#"/>
									<xsl:with-param name="datatype" select="'numeric'"/>
									<xsl:with-param name="mask" select="'#thisMask#'"/>
								</xsl:call-template>
							</cfif>
						</div>
					</td>
				</cfif>
			</cfloop>
		</tr> 
	 </xsl:template>


	<!--- 
	
			Data Display and formatting templates 
			
	--->
	<xsl:template name="DisplayColumnHeaders">
		<tr class="header" id="headersRow">
			<cfloop from="1" to="#NumberOfColumns#" index="i">
				<th class="ReportHeaderCell" id="ReportHeaderCell_#i#">#XMLFormat(ListGetAt(ColumnHeaders,i))#</th>
			</cfloop>
		</tr>
	</xsl:template>


	<xsl:template name="DisplayGroupTotalLabel">
	 	<xsl:param name="value" />
	 	<xsl:param name="GroupName" />
		<xsl:choose>
			<xsl:when test="contains($value, '%g')">
				<xsl:call-template name="str:subst">
					<xsl:with-param name="text" select="$value"/>
					<xsl:with-param name="replace" select="'%g'"/>
					<xsl:with-param name="with" select="$GroupName"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="DisplayEmptyRow">
		<tr>
			<td class="emptyCell">
				<xsl:attribute name="colspan">
					<xsl:value-of select="$NumberOfColumns" />
				</xsl:attribute>
				
			</td>
		</tr>
	</xsl:template>

	
	<xsl:template name="DisplayGroupHeader">
	 	<xsl:param name="value" />
	 	<xsl:param name="datatype" />  
		<xsl:param name="mask" />
		<xsl:param name="GroupLevel" />
		<xsl:param name="index" />

		<tr class="grpHeaderRow">
			<td>
				<xsl:attribute name="colspan">
					<xsl:value-of select="$NumberOfColumns" />
				</xsl:attribute>
				<xsl:attribute name="class">
					<xsl:value-of select="concat('GroupHeader_', $GroupLevel)" />
				</xsl:attribute>
				<a>
					<xsl:attribute name="name">
						<xsl:value-of select="concat('anchor_', concat($index, concat('_', $GroupLevel)))" />
					</xsl:attribute>
					<xsl:attribute name="class">
						<xsl:value-of select="concat('grpTitle title_', $GroupLevel)" />
					</xsl:attribute>
					<xsl:attribute name="id">
						<xsl:value-of select="concat($index, concat('_', $GroupLevel))"/>	
					</xsl:attribute>
	
					<!--- Display Group Name --->
					<xsl:call-template name="DisplayData">
						<xsl:with-param name="value" select="$value"/>
						<xsl:with-param name="datatype" select="$datatype"/>
						<xsl:with-param name="mask" select="$mask"/>
					</xsl:call-template>
					
				</a>
			</td>
		</tr>
	</xsl:template>
	
	
	<xsl:template name="DisplayData">
	 	<xsl:param name="value" />
	 	<xsl:param name="datatype" select="string" />  <!--- String, numeric, datetime --->
		<xsl:param name="mask">
			<xsl:choose>
				<xsl:when test="$datatype = 'numeric'"><xsl:value-of select="$Default_MaskNumeric" /></xsl:when>
				<xsl:when test="$datatype = 'datetime'"><xsl:value-of select="$Default_MaskDate" /></xsl:when>
			</xsl:choose>		
		</xsl:param>
	 	<xsl:param name="href" select="#Default_EMPTYHREF#" />
		
		<xsl:choose>
			<xsl:when test="$href != '#Default_EMPTYHREF#' and $href != ''">
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="$href" />
					</xsl:attribute>
					<xsl:call-template name="DisplayDataValue">
						<xsl:with-param name="value" select="$value"/>
						<xsl:with-param name="datatype" select="$datatype"/>
						<xsl:with-param name="mask" select="$mask"/>
					</xsl:call-template>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="DisplayDataValue">
					<xsl:with-param name="value" select="$value"/>
					<xsl:with-param name="datatype" select="$datatype"/>
					<xsl:with-param name="mask" select="$mask"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	 </xsl:template>


	<xsl:template name="DisplayDataValue">
	 	<xsl:param name="value" />
	 	<xsl:param name="datatype" select="string" />  <!--- String, numeric, datetime --->
		<xsl:param name="mask" />
		
		<xsl:choose>
			<xsl:when test="$datatype = 'numeric'">
				<xsl:call-template name="DisplayNumber">
					<xsl:with-param name="value" select="$value"/>
					<xsl:with-param name="mask" select="$mask"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$datatype = 'datetime'">
				<xsl:call-template name="DisplayDateTime">
					<xsl:with-param name="value" select="$value"/>
					<xsl:with-param name="mask" select="$mask"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="$value"/>
  		    </xsl:otherwise>
		</xsl:choose>		
	 </xsl:template>


	 <xsl:template name="DisplayNumber">
	 	<xsl:param name="value" select="0" />
		<xsl:param name="mask" select="$Default_MaskNumeric" />
		
		<xsl:choose>
			<xsl:when test="string(number($value)) != 'NaN'">
		 		<xsl:value-of select="format-number($value, $mask)"/>  
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/> 
			</xsl:otherwise>
		</xsl:choose>		
	 </xsl:template>

		
	 <xsl:template name="DisplayDateTime">
	 	<xsl:param name="value" select="NULL" />
		<xsl:param name="mask" select="$Default_MaskDate" />
		<xsl:choose>
			<xsl:when test="string-length($value)>18">	
				<xsl:call-template name="dt:format-date-time">
					<xsl:with-param name="year" select="substring($value,1,4)"/>
					<xsl:with-param name="month" select="substring($value,6,2)"/>
					<xsl:with-param name="day" select="substring($value,9,2)"/>
					<xsl:with-param name="hour" select="substring($value,12,2)"/>
					<xsl:with-param name="minute" select="substring($value,15,2)"/>
					<xsl:with-param name="second" select="substring($value,18,2)"/>
					<xsl:with-param name="format" select="$mask"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/> 
			</xsl:otherwise>
		</xsl:choose>
	 </xsl:template>
	 

	<!--- 
	
			CSS declarations templates 
			
	--->
	<xsl:template name="CSS_Style">
		<cfswitch expression="#reportMode#">
			<cfcase value="Page">
				<cfinclude template="XSL_Style_Print.cfm">
			</cfcase>
			<cfcase value="Display">
				<cfinclude template="XSL_Style2.cfm">
			</cfcase>
			<cfcase value="Labels">
				<cfinclude template="XSL_LabelStyle.cfm">
			</cfcase>
		</cfswitch>
	</xsl:template>

</xsl:stylesheet>
</cfoutput>

