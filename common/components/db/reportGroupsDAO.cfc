<cfcomponent extends="WebReports.common.components.lib.daoFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("wr_report_groups")>
		<cfset setPrimaryKey("reportGroupID","cf_sql_numeric")>
		
		<cfset addColumn("reportID", "cf_sql_numeric")>
		<cfset addColumn("groupID", "cf_sql_numeric")>
	</cffunction>
	
</cfcomponent>