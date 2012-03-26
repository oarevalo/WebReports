<cfcomponent name="storedConnections" extends="layerSuperType">

	<cffunction name="getAll" access="public" returnType="query">
		<cfreturn getDAOFactory().getDAO("storedConnections").getAll()>
	</cffunction>

	<cffunction name="get" access="public" returnType="query">
		<cfargument name="storedConnectionID" datatype="string" required="true">
		<cfreturn getDAOFactory().getDAO("storedConnections").get(arguments.storedConnectionID)>
	</cffunction>
		
	<cffunction name="insertRecord" access="public" returnType="string">
		<cfargument name="connectionName" datatype="string" required="true">
		<cfargument name="datasource" datatype="string" required="true">
		<cfargument name="username" datatype="string" required="true">
		<cfargument name="password" datatype="string" required="true">
		<cfargument name="dbtype" datatype="string" required="true">
		<cfargument name="description" datatype="string" required="true">
		<cfreturn getDAOFactory().getDAO("storedConnections").save(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="updateRecord" access="public">
		<cfargument name="storedConnectionID" datatype="string" required="true">
		<cfargument name="connectionName" datatype="string" required="true">
		<cfargument name="datasource" datatype="string" required="true">
		<cfargument name="username" datatype="string" required="true">
		<cfargument name="password" datatype="string" required="true">
		<cfargument name="dbtype" datatype="string" required="true">
		<cfargument name="description" datatype="string" required="true">
		<cfset arguments.id = arguments.storedConnectionID>
		<cfset getDAOFactory().getDAO("storedConnections").save(argumentCollection = arguments)>
	</cffunction>	

	<cffunction name="deleteRecord" access="public">
		<cfargument name="storedConnectionID" datatype="string" required="true">
		<cfset getDAOFactory().getDAO("storedConnections").delete(arguments.storedConnectionID)>
	</cffunction>		
</cfcomponent>