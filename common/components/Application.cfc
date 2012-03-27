<cfcomponent extends="WebReports.core.coreApp">
	
	<!--- Application settings --->
	<cfset this.name = "WebReports"> 
	<cfset this.sessiontimeout = CreateTimeSpan(1,0,0,0)>
	<cfset this.applicationtimeout = CreateTimeSpan(2,0,0,0)>
	<cfset this.sessionManagement = true> 

	<!--- Framework Settings --->
	<cfset this.paths.app = "/WebReports/">
	<cfset this.paths.core = "/WebReports/core">
	
	<cfset this.dirs.handlers = "handlers">
	<cfset this.dirs.layouts = "layouts">
	<cfset this.dirs.views = "views">
	<cfset this.dirs.modules = "modules">

	<cfset this.mainHandler = "ehGeneral">
	<cfset this.defaultEvent = "ehGeneral.dspMain">
	<cfset this.defaultLayout = "Layout.Main">
	<cfset this.paths.config = "/WebReports/common/config/apps-config.xml">

</cfcomponent>
