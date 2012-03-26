<cfcomponent displayname="ReportRenderBean" hint="This bean is used to store the settings of how to render a report">
	
	<cfscript>
		variables.reportMode = "Display";
		variables.ExportTo = "";
		variables.UseXSL = true;
		variables.ServerSide = false;
		variables.ScreenWidth = 600;
		variables.ScreenHeight = 400;
		variables.maxRows = 999999;
		variables.JSCallBack = "";
	</cfscript>	
	
	<!------------------------------------>
	<!---  ReportMode				------>
	<!------------------------------------>
	<cffunction name="setReportMode" access="public">
		<cfargument name="data" required="yes" type="string">
		<cfset variables.reportMode = arguments.data>
	</cffunction>
	
	<cffunction name="getReportMode" access="public" returntype="string">
		<cfreturn variables.reportMode>
	</cffunction>

	<!------------------------------------>
	<!---  ExportTo					------>
	<!------------------------------------>
	<cffunction name="setExportTo" access="public">
		<cfargument name="data" required="yes" type="string">
		<cfset variables.ExportTo = arguments.data>
	</cffunction>
	
	<cffunction name="getExportTo" access="public" returntype="string">
		<cfreturn variables.ExportTo>
	</cffunction>

	<!------------------------------------>
	<!---  UseXSL					------>
	<!------------------------------------>
	<cffunction name="setUseXSL" access="public">
		<cfargument name="data" required="yes" type="boolean">
		<cfset variables.UseXSL = arguments.data>
	</cffunction>
	
	<cffunction name="getUseXSL" access="public" returntype="boolean">
		<cfreturn variables.UseXSL>
	</cffunction>

	<!------------------------------------>
	<!---  ServerSide				------>
	<!------------------------------------>
	<cffunction name="setServerSide" access="public">
		<cfargument name="data" required="yes" type="boolean">
		<cfset variables.ServerSide = arguments.data>
	</cffunction>
	
	<cffunction name="getServerSide" access="public" returntype="boolean">
		<cfreturn variables.ServerSide>
	</cffunction>

	<!------------------------------------>
	<!---  ScreenWidth				------>
	<!------------------------------------>
	<cffunction name="setScreenWidth" access="public">
		<cfargument name="data" required="yes" type="numeric">
		<cfset variables.ScreenWidth = arguments.data>
	</cffunction>
	
	<cffunction name="getScreenWidth" access="public" returntype="numeric">
		<cfreturn variables.ScreenWidth>
	</cffunction>

	<!------------------------------------>
	<!---  ScreenHeight				------>
	<!------------------------------------>
	<cffunction name="setScreenHeight" access="public">
		<cfargument name="data" required="yes" type="numeric">
		<cfset variables.ScreenHeight = arguments.data>
	</cffunction>
	
	<cffunction name="getScreenHeight" access="public" returntype="numeric">
		<cfreturn variables.ScreenHeight>
	</cffunction>
	
	<!------------------------------------>
	<!---  maxRows					------>
	<!------------------------------------>
	<cffunction name="setMaxRows" access="public">
		<cfargument name="data" required="yes" type="numeric">
		<cfset variables.MaxRows = arguments.data>
	</cffunction>
	
	<cffunction name="getMaxRows" access="public" returntype="numeric">
		<cfreturn variables.MaxRows>
	</cffunction>

	<!------------------------------------>
	<!---  JSCallBack				------>
	<!------------------------------------>
	<cffunction name="setJSCallBack" access="public">
		<cfargument name="data" required="yes" type="string">
		<cfset variables.JSCallBack = arguments.data>
	</cffunction>
	
	<cffunction name="getJSCallBack" access="public" returntype="string">
		<cfreturn variables.JSCallBack>
	</cffunction>


	
</cfcomponent>