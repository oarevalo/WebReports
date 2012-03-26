<cfinterface>

	<cffunction name="init" access="public" returntype="dataProvider">
		<cfargument name="ds" type="datasource" required="true">
	</cffunction>

	<cffunction name="getData" access="public" returntype="query">
		<cfargument name="report" type="report" required="true">
		<cfargument name="maxRows" type="numeric" required="true">
	</cffunction>

	<cffunction name="getValuesByColumn" access="public" returntype="query">
		<cfargument name="columnName" type="string" required="true">
		<cfargument name="source" type="string" required="true">
		<cfargument name="maxRows" type="numeric" required="true">
	</cffunction>
	
	<cffunction name="getTables" access="public" returntype="Array">
	</cffunction>

	<cffunction name="getTableColumns" access="public" returntype="Array">
		<cfargument name="tableName" type="string" required="true">
	</cffunction>
	
	<cffunction name="getTypes" access="public" returntype="query">
	</cffunction>

	<cffunction name="ping" access="public" returntype="boolean">
	</cffunction>
	
</cfinterface>