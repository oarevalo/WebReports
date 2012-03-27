<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<cfparam name="request.requestState.viewTemplatePath" default="">
<cfparam name="request.requestState.versionTag" default="">
<cfparam name="request.requestState.debugMode" default="">
<cfparam name="request.requestState.showDBDialog" default="false">
<cfparam name="request.requestState.datasourceBean" default="">
<cfparam name="request.requestState.logoImageURL" default="">
<cfparam name="request.requestState.logoLinkURL" default="">

<cfset versionTag = request.requestState.versionTag>
<cfset debugMode = request.requestState.debugMode>
<cfset datasourceBean = request.requestState.datasourceBean>
<cfset showDBDialog = request.requestState.showDBDialog>
<cfset logoImageURL = request.requestState.logoImageURL>
<cfset logoLinkURL = request.requestState.logoLinkURL>

<cfset messageBoxClass = "fancyMessageBox">

<cfset cfempireURL = "http://www.cfempire.com">
		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>WebReports Designer</title>
		<link rel="stylesheet" type="text/css" href="/WebReports/common/styles/common.css" />
		<link rel="stylesheet" type="text/css" href="/WebReports/common/styles/colors.css" />
		<link rel="stylesheet" type="text/css" href="style.css" />
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
		<script type="text/javascript" src="/WebReports/common/scripts/ajax-core.js"></script>
		<script type="text/javascript" src="/WebReports/common/scripts/common-ui.js"></script>
		<script type="text/javascript" src="/WebReports/common/scripts/util.js"></script>
		<script src="Main.js" type="text/javascript"></script>
		<script language="JavaScript" type="text/javascript" src="/WebReports/common/scripts/prototype.js"></script>
		<script language="JavaScript" type="text/javascript" src="/WebReports/common/scripts/scriptaculous-js-1.6.5/src/scriptaculous.js"></script>
		<script>
			window.onresize = resizePanes;
		</script>
	</head>
	<body onload="<cfoutput>setupUI('#ucase(yesNoformat(showDBDialog))#');</cfoutput>">
		<!--- display header --->
		<table id="ViewerHeader" width="100%" height="50">
			<tr>
				<td>
					<!--- logo --->
					<cfoutput>
						<cfif logoImageURL neq "">
							<a href="#logoLinkURL#" target="_blank"><img src="#logoImageURL#" border="0" align="absmiddle" title="WebReports Viewer" style="width:140px;height:26px;border:1px solid white;"></a>
						</cfif>
					</cfoutput>
				</td>
				<td align="right">
					<h1 id="reportTitle">WebReports</h1>
					<h2 id="reportSubtitle">Report Designer</h2>				
				</td>
			</tr>
		</table>
		
		<!--- display menu bar --->
		<table cellpadding="0" cellspacing="0" width="100%" id="ViewerMenuBar">
			<tr>
				<td align="left" id="menuButtons">
					<li><a href="index.cfm"><img src="images/home-icon5.gif" border="0" align="absmiddle" style="##margin-top:5px;"> Home</a></li>
					<li><a href="##" onclick="resetReport();"><img src="images/page_white.png" border="0" align="absmiddle" style="##margin-top:5px;"> New</a></li>
					<li><a href="javascript:openBrowser('ehFileBrowser.dspBrowser','openReport')"><img src="images/folder.png" border="0" align="absmiddle" style="##margin-top:5px;"> Open</a></li>
					<li><a href="javascript:openBrowser('ehFileBrowser.dspBrowser','saveReport')"><img src="images/disk.png" border="0" align="absmiddle" style="##margin-top:5px;"> Save</a></li>
					<li><a href="javascript:openDatabasePanel()"><img src="images/database.png" border="0" align="absmiddle" style="##margin-top:5px;"> Database</a></li>
					<li><a href="javascript:openSettingsPanel()"><img src="images/cog.png" border="0" align="absmiddle" style="##margin-top:5px;"> Settings</a></li>
					<li><a href="javascript:loadReport()"><img src="images/arrow_refresh.png" border="0" align="absmiddle" style="##margin-top:5px;"> Refresh Preview</a></li>
				</td>
				<td align="right" id="menuIcons">
					<a href="?event=ehGeneral.doExit"><img src="../common/images/door2.gif" alt="Exit Report Designer" title="Exit Report Designer" border="0" align="absmiddle"></a> 
				</td>
			</tr>
		</table>			
		
		
		<cfoutput>
			<div id="mainContent">
				<!--- Display any system messages sent from the event hander --->
				<cfif request.requestState.messageTemplatePath neq "">
					<cfinclude template="#request.requestState.messageTemplatePath#">
				</cfif>

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
		</cfoutput>

		<!--- DialogPanel and statusBar content containers --->
		<div id="DialogPanelContainer" style="display:none;"></div>
		<div id="StatusBar"></div>
		
		<div style="position:absolute;bottom:5px;left:10px;">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td align="left" style="font-size:10px;font-family:verdana;">
						<cfoutput>
							<a href="#cfempireURL#" target="_blank">
								<img src="../common/images/cfempire_logo.jpg" border="0" align="absmiddle" title="CFEmpire Corp."></a>
							<span style="font-size:9px;font-family:verdana;">
								&nbsp;&nbsp;v.#versionTag#
							</span>
						</cfoutput>
						<cfif isBoolean(debugMode) and debugMode>
							<select onChange="if(this.value!='') loadInIFrame(this.value,true)"
									style="font-size:10px;font-family:verdana;width:75px;">
								<option value="">- Debug -</option>
								<option value="includes/debug_SQL.cfm">View SQL</option>
								<option value="?event=ehReportRenderer.dspXSL">View XSL</option>
								<option value="?event=ehReportRenderer.dspMain&UseXSL=false">View XML Data</option>
								<option value="includes/dumpReport.cfm">Dump Report</option>
							</select>
							&nbsp;&nbsp;&nbsp;&nbsp;
						</cfif>
						<cfoutput>
							<cfif datasourceBean.getName() neq "">
								<b>#datasourceBean.getName()#</b>
								(#datasourceBean.getDBType()#)
							<cfelse>	
								<em>Not Connected</em>
							</cfif>
						</cfoutput>
					</td>
					<td align="right" width="300">
						<div id="loadingImage" class="hidelayer">
							<img src="images/ajax-loader.gif">&nbsp;	
						</div>		
					</td>
				</tr>
			</table>
		</div>
		<script type="text/javascript">
			showMessageBox();
		</script>
	</body>
</html>
