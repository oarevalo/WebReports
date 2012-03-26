<cfcomponent extends="WebReports.common.components.lib.daoFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("wr_StoredConnections")>
		<cfset setPrimaryKey("StoredConnectionID","cf_sql_numeric")>
		
		<cfset addColumn("connectionName", "cf_sql_varchar")>
		<cfset addColumn("datasource", "cf_sql_varchar")>
		<cfset addColumn("username", "cf_sql_varchar")>
		<cfset addColumn("password", "cf_sql_varchar")>
		<cfset addColumn("dbtype", "cf_sql_varchar")>
		<cfset addColumn("description", "cf_sql_varchar")>
	</cffunction>
	
</cfcomponent>