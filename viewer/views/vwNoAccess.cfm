<cfif structKeyExists(session,"ExitURL") and session.ExitURL is not "">
	<link rel="stylesheet" type="text/css" href="/WebReports/common/styles/Style_Main.css">
	<link rel="stylesheet" type="text/css" href="/WebReports/common/styles/Style_Blue.css">
	<br><br>
	<cfoutput>
		<img src="images/bullet_go.png" align="absmiddle">
		<a href="#session.ExitURL#">Exit Report Viewer</a> 
	</cfoutput>
</cfif>
