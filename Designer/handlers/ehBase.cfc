<cfcomponent name="ehBase" extends="eventHandler">

	<!--- define shared functions --->

	<cffunction name="dspDatabaseRequiredPod" access="public" returntype="void">
		<cfset setView("vwDatabaseRequiredPod")>
		<cfset setLayout("Layout.None")>
	</cffunction>

	<cffunction name="dspDatasourceRequiredPod" access="public" returntype="void">
		<cfset setView("vwDatasourceRequiredPod")>
		<cfset setLayout("Layout.None")>
	</cffunction>

	<cffunction name="dspErrorPod" access="public" returntype="void">
		<cfset setView("vwErrorPod")>
		<cfset setLayout("Layout.None")>
	</cffunction>

	<cffunction name="dspStatusBar" access="public" returntype="void">
		<cfset setView("vwStatusBar")>
		<cfset setLayout("Layout.Clean")>
	</cffunction>
			
	<cffunction name="getDatasourceBean" access="package" returntype="WebReports.Common.Components.datasource">
		<cfreturn session.oDataSourceBean>
	</cffunction>		

	<cffunction name="getReport" access="package" returntype="WebReports.Common.Components.Report">
		<cfreturn session.oReport>
	</cffunction>	

	<cffunction name="getDataProvider" access="package" returntype="WebReports.Common.Components.dataProvider">
		<cfreturn createObject("component", session.dataProviderType).init( getDatasourceBean() )>
	</cffunction>		

</cfcomponent>