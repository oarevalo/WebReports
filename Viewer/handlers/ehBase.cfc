<cfcomponent name="ehBase" extends="eventHandler">

	<cffunction name="dspErrorPanel" access="public" returntype="void">
		<cfset setView("vwErrorPanel")>
		<cfset setLayout("Layout.None")>
	</cffunction>
	
	<!--- define shared functions --->
	<cffunction name="getDatasourceBean" access="package" returntype="WebReports.Common.Components.datasource">
		<cfreturn session.oDataSourceBean>
	</cffunction>		

	<cffunction name="getReport" access="package" returntype="WebReports.Common.Components.Report">
		<cfreturn session.oReport>
	</cffunction>	

	<cffunction name="getDatasources" access="private" returntype="any">
		<cfset var oFactory = CreateObject("java", "coldfusion.server.ServiceFactory")>
		<cfset var stDS = oFactory.DataSourceService.getDatasources()>
		<cfset var aRet = StructKeyArray(stDS)>
		<cfset ArraySort(aRet, "textnocase", "asc")>
		<cfreturn aRet>
	</cffunction>

	<cffunction name="getDataProvider" access="package" returntype="WebReports.Common.Components.dataProvider">
		<cfreturn createObject("component", session.dataProviderType).init( getDatasourceBean() )>
	</cffunction>		

</cfcomponent>