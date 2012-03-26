<cfcomponent extends="WebReports.common.components.lib.daoFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("customers")>
		<cfset setPrimaryKey("customerID","cf_sql_numeric")>
		
		<cfset addColumn("firstName", "cf_sql_varchar")>
		<cfset addColumn("lastName", "cf_sql_varchar")>
		<cfset addColumn("email", "cf_sql_varchar")>
		<cfset addColumn("city", "cf_sql_varchar")>
		<cfset addColumn("state", "cf_sql_varchar")>
		<cfset addColumn("phone", "cf_sql_varchar")>
	</cffunction>
	
</cfcomponent>