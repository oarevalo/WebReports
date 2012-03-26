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
		<cfset var oDAO = 0>

		<!--- Generate the SQL statement to obtain the report  ---->
		<cfset stReportSQL = arguments.report.renderSQL()>
		
		<!--- Check that we have all elements of the SQL statement --->
		<cfif stReportSQL.source eq "">
			<cfthrow message="No source table or view has been selected." type="com.cfempire.webreports.rendering.noSourceException">
		</cfif>
		<cfif stReportSQL.columnList eq "">
			<cfthrow message="No columns have been selected." type="com.cfempire.webreports.rendering.noColumnsException">
		</cfif>
		
		<cfset oDAO = getDAO( stReportSQL.source )>
		<cfset qryData = oDAO.getAll()>
		
		<!--- Query database to get actual data --->
		<cfquery name="qryData" dbtype="query" maxrows="#arguments.maxRows#">
			 SELECT #stReportSQL.distinct# #PreserveSingleQuotes(stReportSQL.columnList)#
				FROM qryData
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
		<cfset var oDAO = 0>

		<cfset oDAO = getDAO( arguments.source )>
		<cfset qry = oDAO.getAll()>
		
		<cfquery name="qry" dbtype="query" maxrows="#arguments.maxRows#" cachedwithin="#cacheTime#"> 
			SELECT DISTINCT #arguments.columnName# AS Item,  
					#arguments.columnName# AS ItemDisplay
					FROM qry
					ORDER BY #arguments.columnName#
		</cfquery>
		
		<cfreturn qry />
	</cffunction>
	
	<cffunction name="getTables" access="public" returntype="Array">
		<cfset var ds = variables.instance.oDatasource>
		<cfset var dataRoot = listFirst(ds.getName(),";")>
		<cfset var qry = 0>
		<cfdirectory action="list" directory="#expandPath(dataRoot)#" filter="*.xml" name="qry">
		<cfreturn listToArray(valueList(qry.name))>
	</cffunction>

	<cffunction name="getTableColumns" access="public" returntype="Array">
		<cfargument name="tableName" type="string" required="true">
		<cfset var oDAO = 0>
		<cfset oDAO = getDAO( arguments.tableName )>
		<cfreturn listToArray(structKeyList(oDAO.getColumnStruct()))>
	</cffunction>

	<cffunction name="getTypes" access="public" returntype="query">
		<cfset var qryTypes = queryNew("type,name")>
		<cfset queryAddRow(qryTypes)>
		<cfset querySetCell(qryTypes,"type","default")>
		<cfset querySetCell(qryTypes,"name","default")>
		<cfreturn qryTypes>
	</cffunction>
	
	<cffunction name="ping" access="public" returntype="boolean">
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getDAO" access="private" returntype="Any">
		<cfargument name="entity" type="string" required="true">

		<cfset var oConfigBean = 0>
		<cfset var oDataProvider = 0>
		<cfset var daoRoot = "">
		<cfset var dataRoot = "">
		<cfset var ds = variables.instance.oDatasource>

		<cfif arguments.entity eq "">
			<cfthrow message="No source table or view has been selected." type="com.cfempire.webreports.rendering.noSourceException">
		</cfif>

		<cfset dataRoot = listFirst(ds.getName(),";")>
		<cfset daoRoot = listLast(ds.getName(),";")>
	
		<cfset oConfigBean = createObject("component","WebReports.common.components.lib.daoFactory.xmlDataProviderConfigBean").init()>
		<cfset oConfigBean.setDataRoot( dataRoot )>

		<cfset oDataProvider = createObject("component", "WebReports.common.components.lib.daoFactory.xmlDataProvider").init( oConfigBean )>

		<cfreturn createObject("component", daoRoot & replaceNoCase(arguments.entity,".xml","") &  "DAO").init( oDataProvider )>	
	</cffunction>
		
</cfcomponent>