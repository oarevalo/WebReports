<cfcomponent implements="dataProvider">

	<cfset variables.instance = structNew()>
	<cfset variables.instance.oDatasource = 0>
	
	<cffunction name="init" access="public" returntype="dataProvider">
		<cfargument name="ds" type="datasource" required="true">
		<cfset variables.instance.oDatasource = arguments.ds>
		<cfreturn this>
	</cffunction>

	<cffunction name="getData" access="public" returntype="query">
		<cfargument name="report" type="report" required="true">
		<cfargument name="maxRows" type="numeric" required="true">

		<cfset var stReportSQL = structNew()>
		<cfset var qryData = 0>
		<cfset var ds = variables.instance.oDatasource>

		<!--- Generate the SQL statement to obtain the report  ---->
		<cfset stReportSQL = arguments.report.renderSQL()>
		
		<!--- Check that we have all elements of the SQL statement --->
		<cfif stReportSQL.source eq "">
			<cfthrow message="No source table or view has been selected." type="com.cfempire.webreports.rendering.noSourceException">
		</cfif>
		<cfif stReportSQL.columnList eq "">
			<cfthrow message="No columns have been selected." type="com.cfempire.webreports.rendering.noColumnsException">
		</cfif>
		
		<!--- Query database to get actual data --->
		<cfquery name="qryData"
					datasource="#ds.getName()#"
					username="#ds.getUserName()#"
					password="#ds.getPassword()#"
					maxrows="#arguments.maxRows#">
			 SELECT #stReportSQL.distinct# #PreserveSingleQuotes(stReportSQL.columnList)#
				FROM #PreserveSingleQuotes(stReportSQL.source)#
				<cfif stReportSQL.where neq "">
					WHERE #PreserveSingleQuotes(stReportSQL.where)#
				</cfif>
		</cfquery>

		<cfreturn qryData>
	</cffunction>

	<cffunction name="getValuesByColumn" access="public" returntype="query">
		<cfargument name="columnName" type="string" required="true">
		<cfargument name="source" type="string" required="true">
		<cfargument name="maxRows" type="numeric" required="true">
		<cfset var qry = 0>
		<cfset var cacheTime = CreateTimeSpan(0,0,5,0)>
		<cfset var ds = variables.instance.oDatasource>
		
		<cfquery name="qry" 
				 maxrows="#arguments.maxRows#"
				 datasource="#ds.getName()#"
				 username="#ds.getUserName()#"
				 password="#ds.getPassword()#"
				 cachedwithin="#cacheTime#">
			SELECT DISTINCT #arguments.columnName# AS Item,  
					#arguments.columnName# AS ItemDisplay
					FROM #PreserveSingleQuotes(arguments.source)# 
					ORDER BY #arguments.columnName#
		</cfquery>
		
		<cfreturn qry />
	</cffunction>
	
	<cffunction name="getTables" access="public" returntype="Array">
		<cfset var ds = variables.instance.oDatasource>
		<cfset var oDataMgr = createObject("Component","WebReports.Common.Components.lib.DataMgr.DataMgr").init(ds)>
		<cfset var lstTables = oDataMgr.getDatabaseTables()>
		<cfreturn listToArray(lstTables)>
	</cffunction>

	<cffunction name="getTableColumns" access="public" returntype="Array">
		<cfargument name="tableName" type="string" required="true">
		<cfset var ds = variables.instance.oDatasource>
		<cfset var oDataMgr = createObject("Component","WebReports.Common.Components.lib.DataMgr.DataMgr").init(ds)>
		<cfset var lstFields = oDataMgr.getFieldList(arguments.tableName)>
		<cfreturn listToArray(lstFields)>
	</cffunction>

	<cffunction name="getTypes" access="public" returntype="query">
		<cfset var oDataMgr = createObject("Component","WebReports.Common.Components.lib.DataMgr.DataMgr").init()>
		<cfset var qry = oDataMgr.getSupportedDatabases()>
		<cfset var qryTypes = queryNew("type,name")>
		<cfloop query="qry">
			<cfset queryAddRow(qryTypes)>
			<cfset querySetCell(qryTypes,"type",qry.database)>
			<cfset querySetCell(qryTypes,"name",qry.databasename)>
		</cfloop>
		<cfreturn qryTypes>
	</cffunction>

	<cffunction name="getDatasource" access="public" returntype="datasource">
		<cfreturn variables.instance.oDatasource>
	</cffunction>

	<cffunction name="ping" access="public" returntype="boolean">
		<cfset var oConn = 0>
		<cfset var isUP = false>
		<cfset var dsn = "">
		<cftry>
			<cfset dsn = getDatasource().getName()>
			<cfdump var="#CreateObject("java","coldfusion.server.ServiceFactory").getDataSourceService().getDatasource(dsn)#">
			<cfabort>
			<cfset oConn = CreateObject("java","coldfusion.server.ServiceFactory").getDataSourceService().getDatasource(dsn).getConnection()>
			<cfset isUP = true>
			<cfcatch type="lock">
				<cfset isUP = false>
			</cfcatch>
		</cftry>
		<cfif not isSimpleValue(oConn)>
			<cfset oConn.close()>
		</cfif>
		<cfreturn isUP>
	</cffunction>
			
</cfcomponent>