<cfcomponent name="type" hint="Acts as an abstract component to define the interface for different value types">
	
	<cfset variables.qryValues = QueryNew("value,label")>
	<cfset variables.description = "This is a data type">
	
	<!----- PUBLIC INTERFACE ----->
	
	<cffunction name="init" returntype="any">
		<cfreturn this>
	</cffunction>

	<cffunction name="getValues" returntype="query" hint="Returns all possible values for this type">
		<cfreturn variables.qryValues>
	</cffunction>
	
	<cffunction name="getDescription" returnType="string" hint="Returns a description of this data type">
		<cfreturn variables.description>
	</cffunction>


	<!----- PRIVATE INTERFACE ----->

	<cffunction name="addValue" access="private" hint="Adds a possible value for this type">
		<cfargument name="value" type="string" required="true">
		<cfargument name="label" type="string" required="false" hint="User friendly label for this value" default="#arguments.value#">
		<cfset QueryAddRow(variables.qryValues)>
		<cfset QuerySetCell(variables.qryValues, "value", arguments.value)>
		<cfset QuerySetCell(variables.qryValues, "label", arguments.label)>
	</cffunction> 

	<cffunction name="setDescription" access="private">
		<cfargument name="description" type="string" required="true">
		<cfset variables.description = arguments.description>
	</cffunction>	
</cfcomponent>