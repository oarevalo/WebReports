<cfcomponent name="ehBase" extends="eventHandler">

	<cffunction name="dspErrorPanel" access="public" returntype="void">
		<cfset setView("vwErrorPanel")>
		<cfset setLayout("Layout.None")>
	</cffunction>
	
	<!--- define shared functions --->
	<cffunction name="getDatasourceBean" access="package" returntype="WebReports.common.components.datasource">
		<cfreturn session.oDataSourceBean>
	</cffunction>		

	<cffunction name="getReport" access="package" returntype="WebReports.common.components.Report">
		<cfreturn session.oReport>
	</cffunction>	

	<cffunction name="getDataProvider" access="package" returntype="WebReports.common.components.dataProvider">
		<cfreturn createObject("component", session.dataProviderType).init( getDatasourceBean() )>
	</cffunction>		

</cfcomponent>