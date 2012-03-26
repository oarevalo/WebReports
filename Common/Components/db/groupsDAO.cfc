<cfcomponent extends="WebReports.Common.Components.lib.daoFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("wr_groups")>
		<cfset setPrimaryKey("groupID","cf_sql_numeric")>
		
		<cfset addColumn("groupName", "cf_sql_varchar")>
		<cfset addColumn("description", "cf_sql_varchar")>
	</cffunction>
	
</cfcomponent>