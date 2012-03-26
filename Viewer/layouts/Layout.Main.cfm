<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<cfsetting showdebugoutput="false">

<cfparam name="request.requestState.viewTemplatePath" default="">
<cfparam name="request.requestState.versionTag" default="">
<cfparam name="request.requestState.debugMode" default="">
<cfparam name="request.requestState.showDBDialog" default="false">
<cfparam name="request.requestState.datasourceBean" default="">
<cfparam name="request.requestState.oReport" default="">
<cfparam name="request.requestState.logoImageURL" default="">
<cfparam name="request.requestState.logoLinkURL" default="">

<cfset versionTag = request.requestState.versionTag>
<cfset debugMode = request.requestState.debugMode>
<cfset debugMode = isBoolean(debugMode) and debugMode>
<cfset datasourceBean = request.requestState.datasourceBean>
<cfset showDBDialog = request.requestState.showDBDialog>
<cfset showDBDialog = isBoolean(showDBDialog) and showDBDialog>
<cfset logoImageURL = request.requestState.logoImageURL>
<cfset logoLinkURL = request.requestState.logoLinkURL>

<cfset oReport = request.requestState.oReport>
<cfset reportTitle = oReport.getTitle()>
<cfset reportSubtitle = oReport.getSubtitle()>

<cfif structKeyExists(session,"ExitURL") and session.ExitURL is not "">
	<cfset exitURL = session.ExitURL>
<cfelse>
	<cfset exitURL = "/WebReports">
</cfif>

<cfset cfempireURL = "http://www.cfempire.com">
		
<cfoutput>
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>WebReports Viewer :: #reportTitle#</title>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
		<link rel="stylesheet" type="text/css" href="/WebReports/Common/Styles/common.css" />
		<link rel="stylesheet" type="text/css" href="/WebReports/Common/Styles/colors.css" />
		<link rel="stylesheet" type="text/css" href="style.css">
		<script type="text/javascript" src="/WebReports/Common/Scripts/ajax-core.js"></script>
		<script type="text/javascript" src="/WebReports/Common/Scripts/common-ui.js"></script>
		<script type="text/javascript" src="/WebReports/Common/Scripts/util.js"></script>
		<script type="text/javascript" src="main.js"></script>
		<script language="JavaScript" type="text/javascript" src="/WebReports/Common/Scripts/prototype.js"></script>
		<script language="JavaScript" type="text/javascript" src="/WebReports/Common/Scripts/scriptaculous-js-1.6.5/src/scriptaculous.js"></script>
		<script>
			window.onresize = resizePanes;
		</script>
	</head>
	<body onload="setupUI('#showDBDialog#');">
		<!--- display header --->
		<table id="ViewerHeader" width="100%" height="50">
			<tr>
				<td>
					<!--- logo --->
					<cfif logoImageURL neq "">
						<a href="#logoLinkURL#" target="_blank"><img src="#logoImageURL#" border="0" align="absmiddle" title="WebReports Viewer" style="width:140px;height:26px;border:1px solid white;"></a>
					</cfif>
				</td>
				<td align="right">
					<h1 id="reportTitle">#reportTitle#</h1>
					<h2 id="reportSubtitle">#reportSubtitle#</h2>				
				</td>
			</tr>
		</table>
		
		<!--- display menu bar --->
		<table cellpadding="0" cellspacing="0" width="100%" id="ViewerMenuBar">
			<tr>
				<td align="left" id="menuButtons">
					<li><a href="javascript:dialogEvent('ehReport.dspSettings')">Settings</a></li>
					<li><a href="javascript:dialogEvent('ehColumns.dspMain')">Columns</a></li>
					<li><a href="javascript:dialogEvent('ehFilters.dspMain')">Filters</a></li>
					<li><a href="javascript:dialogEvent('ehSort.dspMain')">Sort</a></li>
					<li><a href="javascript:dialogEvent('ehGroups.dspMain')">Groups</a></li>
				</td>

				<td style="padding-left:50px;font-weight:bold;">
					<div id="chkHideGrpContentsPanel">
						<input type="checkbox" name="chkHideGrpContents"
								style="border:0px;"
								onclick="doEvent('ehReport.doSetReportProperty','DialogPanelContainer',{propName:'displayGroupContents',propValue:!this.checked,reload:true})"> Hide Data Rows
					</div>
				</td>

				<cfif debugMode>
					<td>
						<select onChange="if(this.value!='') loadInIFrame(this.value,true)">
							<option value="">--- Debug Options ---</option>
							<option value="?event=ehReportRenderer.dspXSL">View XSL</option>
							<option value="?event=ehReportRenderer.dspMain&UseXSL=false">View XML Data</option>
							<!--- <option value="ViewerMain_CacheInfo.cfm">View Cache Info</option> --->
						</select>
					</td>
				</cfif>	

				<td align="right" id="menuIcons">
					<a href="##" onclick="loadReport()"><img src="../Common/Images/refresh2.gif" border="0" title="Refresh Report" align="absmiddle"></a>
					<a href="##" onclick="openReport('Page','excel')"><img src="../Common/Images/excel.gif" border="0" title="Export to Microsoft Excel" align="absmiddle"></a>
					<a href="##" onclick="openReport('Page','')"><img src="../Common/Images/Printer.gif" border="0" title="Printer friendly format" align="absmiddle"></a>
					<!---
					<a href="javascript:openReport('Page','word')"><img src="../Common/Images/word.gif" border="0" title="Export to Microsoft Word" align="absmiddle"></a>
					--->
					<cfif ExitURL is not "">
						<a href="#ExitURL#"><img src="../Common/Images/door2.gif" alt="Exit Report Viewer" title="Exit Report Viewer" border="0" align="absmiddle"></a> 
					</cfif>
				</td>
			</tr>
		</table>			
		
		<div id="mainContent">
			<!--- Display any system messages sent from the event hander --->
			<cfinclude template="../includes/message.cfm">

			<cftry>
				<!--- Render the view --->
				<cfif request.requestState.viewTemplatePath neq "">
					<cfinclude template="#request.requestState.viewTemplatePath#">
				</cfif>
										
				<cfcatch type="any">
					<p>#cfcatch.message#</p>
				</cfcatch>
			</cftry> 
		</div>

		<!--- DialogPanel content container --->
		<div id="DialogPanelContainer" style="display:none;"></div>
		
		<div style="position:absolute;bottom:5px;left:10px;">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td style="width:200px;">
						<a href="#cfempireURL#" target="_blank">
							<img src="../Common/Images/cfempire_logo.jpg" border="0" align="absmiddle" title="CFEmpire Corp."></a>
						<span style="font-size:9px;font-family:verdana;">
							&nbsp;&nbsp;v.#versionTag#
						</span>
					</td>
					<td align="right" id="ReportCriteriaPanel"></td>
					<td id="StatusBar" align="left" style="font-size:10px;font-family:verdana;">&nbsp;</td>
					<td align="right" width="300">
						<div id="loadingImage" class="hidelayer">
							<img src="images/ajax-loader.gif">&nbsp;	
						</div>		
					</td>
				</tr>
			</table>
		</div>
	</body>
</html>
</cfoutput>
