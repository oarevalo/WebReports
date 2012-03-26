<cfcomponent extends="WebReports.common.components.lib.daoFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("wr_report_users")>
		<cfset setPrimaryKey("reportUserID","cf_sql_numeric")>
		
		<cfset addColumn("reportID", "cf_sql_numeric")>
		<cfset addColumn("userID", "cf_sql_numeric")>
	</cffunction>
	
</cfcomponent>