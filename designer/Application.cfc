<cfcomponent displayname="Controller" extends="WebReports.Application">
	
	<!--- Application settings --->
	<cfset this.name = "WebReportsDesigner"> 

	<!--- Framework settings --->
	<cfset this.defaultEvent = "ehGeneral.dspMain">
	<cfset this.defaultLayout = "Layout.Main">
	<cfset this.appPath = "/WebReports/designer">
	<cfset this.forceRedir = "">

</cfcomponent>
