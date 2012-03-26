<cfcomponent extends="WebReports.common.components.lib.daoFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("wr_users")>
		<cfset setPrimaryKey("userID","cf_sql_numeric")>
		
		<cfset addColumn("username", "cf_sql_varchar")>
		<cfset addColumn("password", "cf_sql_varchar")>
		<cfset addColumn("firstName", "cf_sql_varchar")>
		<cfset addColumn("middleName", "cf_sql_varchar")>
		<cfset addColumn("lastName", "cf_sql_varchar")>
		<cfset addColumn("isDeveloper", "cf_sql_numeric")>
		<cfset addColumn("isAdmin", "cf_sql_numeric")>
		<cfset addColumn("createdDate", "cf_sql_date")>
	</cffunction>
	
</cfcomponent>