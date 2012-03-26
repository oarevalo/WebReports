
<!--- This file performs all processing related to WebReportsCache --->

<cfset tmpSource = "">

<!--- Check if the report is in the cache--->
<cfif UseCacheIfAvailable or CreateCacheIfNotFound>
	<cfstoredproc procedure="usp_Cache_GetReport"
				 datasource="#cacheDatasource#"
				 username="#cacheUserName#"
				 password="#cachePassword#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#session.DataSource#"> 
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#thisReport.TableName#"> 
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#thisReport.FunctionParameters#"> 
			<cfprocparam type="out" cfsqltype="cf_sql_varchar" variable="cacheTable"> 
	</cfstoredproc>
</cfif>

<cfif CreateCacheIfNotFound and (cacheTable eq "" or RefreshCache eq "1")>
	<!--- Create cache --->
	<cfset tmpSource = "database">
	
	<!--- get data from report's database --->
	<cfquery name="qryData"
			 datasource="#session.DataSource#"
			 username="#session.UserName#"
			 password="#session.Password#">
		SELECT * 
			FROM #PreserveSingleQuotes(stReportSQL.source)# 
			FOR XML AUTO, ELEMENTS
	</cfquery>
	<cfset QueryLoadTime = cfquery.executionTime>

	<!--- get resultset structure --->
	<cfquery name="qryStruct"
			 datasource="#session.DataSource#"
			 username="#session.UserName#"
			 password="#session.Password#">
		SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_PRECISION_RADIX
			FROM INFORMATION_SCHEMA.COLUMNS colData
			WHERE TABLE_NAME = '#thisReport.TableName#'
		UNION
		SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_PRECISION_RADIX
			FROM INFORMATION_SCHEMA.ROUTINE_COLUMNS colData
			WHERE TABLE_NAME = '#thisReport.TableName#'
		FOR XML AUTO, ELEMENTS
	</cfquery>

	<!--- transform returned queries into strings --->
	<cfset xmlData = xml2String(qryData,"reportData")> 
	<cfset xmlStruct = xml2String(qryStruct,"structData")> 

	<!--- Save the report in the cache --->
	<cfstoredproc procedure="usp_Cache_PutReport"
				 datasource="#cacheDatasource#"
				 username="#cacheUserName#"
				 password="#cachePassword#" 
				 returncode="yes">
		<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#session.DataSource#"> 
		<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#thisReport.TableName#"> 
		<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#thisReport.FunctionParameters#" null="#iif(trim(thisReport.FunctionParameters) eq "",1,0)#">
		<cfprocparam type="in" cfsqltype="cf_sql_longvarchar" value="#xmlData#"> 
		<cfprocparam type="in" cfsqltype="cf_sql_longvarchar" value="#xmlStruct#"> 
		<cfprocparam type="in" cfsqltype="cf_sql_float" value="#QueryLoadTime#">
		<cfprocparam type="in" cfsqltype="cf_sql_integer" value="1">
		<cfprocparam type="out" cfsqltype="cf_sql_varchar" variable="cacheTable"> 
		<cfprocresult name="BaseTable" resultset="1">
	</cfstoredproc>

	<cflock scope="session" type="exclusive" timeout="10">
		<cfset session.cacheTable = cacheTable>
	</cflock>
</cfif>


<cfif UseCacheIfAvailable and cacheTable neq "">
	<!--- Get data from cache --->
	<cfif tmpSource eq "">
		<cfset tmpSource = "cache">
	</cfif>
	<cfstoredproc procedure="usp_Cache_GetReportData"
				 datasource="#cacheDatasource#"
				 username="#cacheUserName#"
				 password="#cachePassword#" 
				 returncode="yes">
		<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#cacheTable#"> 
		<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#stReportSQL.columnList#"> 
		<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#stReportSQL.distinct#" null="#iif(trim(stReportSQL.distinct) eq "",1,0)#">
		<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#thisReport.TableName#"> 
		<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#PreserveSingleQuotes(stReportSQL.where)#"> 
		<cfprocresult resultset="1" name="qryReport">
	</cfstoredproc>


<cfelse>
	<!--- Get data from DB --->
	<cfset tmpSource = "database">

	<cfquery name="qryReport"
				datasource="#session.Datasource#"
				username="#session.UserName#"
				password="#session.Password#">
		 SELECT #stReportSQL.distinct# #stReportSQL.columnList#
			FROM #PreserveSingleQuotes(stReportSQL.source)#
			<cfif stReportSQL.where neq "">
				WHERE #PreserveSingleQuotes(stReportSQL.where)#
			</cfif>
		 FOR XML AUTO, ELEMENTS
	</cfquery>


	<cfif KeepLogWhenNotCaching>
		<!--- Write entry in log --->
		<cfstoredproc procedure="usp_Cache_AddLogEntry"
					 datasource="#cacheDatasource#"
					 username="#cacheUserName#"
					 password="#cachePassword#" 
					 returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#session.DataSource#"> 
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#thisReport.TableName#"> 
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#thisReport.FunctionParameters#" null="#iif(trim(thisReport.FunctionParameters) eq "",1,0)#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="4"> 
			<cfprocparam type="in" cfsqltype="cf_sql_float" value="#cfquery.executionTime#"> 
		</cfstoredproc>
	</cfif>
</cfif>
