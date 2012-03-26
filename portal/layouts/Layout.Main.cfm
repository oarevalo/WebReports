<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<cfparam name="request.requestState.viewTemplatePath" default="">
<cfparam name="request.requestState.versionTag" default="">
<cfparam name="request.requestState.logoImageURL" default="">
<cfparam name="request.requestState.logoLinkURL" default="">

<cfoutput>

<cfset versionTag = request.requestState.versionTag>
<cfset logoImageURL = request.requestState.logoImageURL>
<cfset logoLinkURL = request.requestState.logoLinkURL>

<cfset cfempireURL = "http://www.cfempire.com">

<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>WebReports Portal</title>
		<link rel="stylesheet" type="text/css" href="/WebReports/common/styles/common.css" />
		<link rel="stylesheet" type="text/css" href="/WebReports/common/styles/colors.css" />
		<link rel="stylesheet" type="text/css" href="style.css">
	</head>

	<body>
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
					<h1 id="reportTitle">WebReports</h1>
					<h2 id="reportSubtitle">Enterprise Portal</h2>				
				</td>
			</tr>
		</table>

		<!--- display menu bar --->
		<cfinclude template="../includes/mainMenu.cfm">

		<div id="mainContent">
			<!--- Display any system messages sent from the event hander --->
			<cfinclude template="../includes/message.cfm">
				
			<!--- Render the view --->
			<cfif request.requestState.viewTemplatePath neq "">
				<cfinclude template="#request.requestState.viewTemplatePath#">
			</cfif>
		</div>
		
		<!--- footer --->
		<div style="position:absolute;bottom:5px;left:10px;font-size:9px;font-family:verdana;">
			<a href="#cfempireURL#" target="_blank">
				<img src="/WebReports/common/images/cfempire_logo.jpg" border="0" align="absmiddle" title="CFEmpire Corp."></a>
			&nbsp;&nbsp;v.#versionTag#
		</div>
		
	</body>
</html>
</cfoutput>

