<cfcomponent name="typeFactory" hint="This component provides an interface to different lists of data types used for the report definition">

	<cffunction name="init" returntype="any">
		<cfreturn this>
	</cffunction>

	<cffunction name="getValues" access="public" returntype="query">
		<cfargument name="typeName" type="string" required="true">
		<cfset oType = createObject("Component", "types." & arguments.typeName & "Type").init()>
		<cfset rtn = oType.getValues()>
		<cfreturn rtn>
	</cffunction>
	
	
</cfcomponent>