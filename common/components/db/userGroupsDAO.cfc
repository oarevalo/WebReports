<cfcomponent extends="WebReports.common.components.lib.daoFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("wr_user_groups")>
		<cfset setPrimaryKey("userGroupID","cf_sql_numeric")>
		
		<cfset addColumn("userID", "cf_sql_numeric")>
		<cfset addColumn("groupID", "cf_sql_numeric")>
	</cffunction>
	
</cfcomponent>