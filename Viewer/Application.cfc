<cfcomponent displayname="Controller" extends="WebReports.Application">
	
	<!--- Application settings --->
	<cfset this.name = "WebReportsViewer"> 

	<!--- Framework settings --->
	<cfset this.defaultEvent = "ehGeneral.dspMain">
	<cfset this.defaultLayout = "Layout.Main">
	<cfset this.appPath = "/WebReports/Viewer">
	<cfset this.forceRedir = "">

</cfcomponent>
