<cfcomponent extends="WebReports.common.components.lib.daoFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("wr_reports")>
		<cfset setPrimaryKey("reportID","cf_sql_numeric")>
		
		<cfset addColumn("reportName", "cf_sql_varchar")>
		<cfset addColumn("reportHREF", "cf_sql_varchar")>
		<cfset addColumn("description", "cf_sql_varchar")>
		<cfset addColumn("storedConnectionID", "cf_sql_varchar")>
		<cfset addColumn("datasource", "cf_sql_varchar")>
		<cfset addColumn("username", "cf_sql_varchar")>
		<cfset addColumn("password", "cf_sql_varchar")>
		<cfset addColumn("dbtype", "cf_sql_varchar")>
		<cfset addColumn("isPublic", "cf_sql_numeric")>
		<cfset addColumn("createdOn", "cf_sql_timestamp")>
	</cffunction>
	
</cfcomponent>