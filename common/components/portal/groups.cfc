<cfcomponent name="storedConnections" extends="layerSuperType">

	<cffunction name="getAll" access="public" returnType="query">
		<cfreturn getDAOFactory().getDAO("groups").getAll()>
	</cffunction>

	<cffunction name="get" access="public" returnType="query">
		<cfargument name="groupID" datatype="string" required="true">
		<cfreturn getDAOFactory().getDAO("groups").get(arguments.groupID)>
	</cffunction>
		
	<cffunction name="insertRecord" access="public" returnType="string">
		<cfargument name="groupName" datatype="string" required="true">
		<cfargument name="description" datatype="string" required="true">
		<cfreturn getDAOFactory().getDAO("groups").save(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="updateRecord" access="public">
		<cfargument name="groupID" datatype="string" required="true">
		<cfargument name="groupName" datatype="string" required="true">
		<cfargument name="description" datatype="string" required="true">
		<cfset arguments.id = arguments.reportID>
		<cfset getDAOFactory().getDAO("groups").save(argumentCollection = arguments)>
	</cffunction>	

	<cffunction name="deleteRecord" access="public">
		<cfargument name="groupID" datatype="string" required="true">
		<cfset getDAOFactory().getDAO("groups").delete(arguments.groupID)>
	</cffunction>		
</cfcomponent>