<cfcomponent>
	
	<cfset variables.instance = structNew()>
	<cfset variables.instance.name = "">
	<cfset variables.instance.username = "">
	<cfset variables.instance.password = "">
	<cfset variables.instance.dbtype = "">
	
	<cffunction name="init" access="public" returntype="datasource">
		<cfargument name="name" type="string" required="false" default="">
		<cfargument name="username" type="string" required="false" default="">
		<cfargument name="password" type="string" required="false" default="">
		<cfargument name="dbtype" type="string" required="false" default="">
		<cfset setName(arguments.name)>
		<cfset setUsername(arguments.username)>
		<cfset setPassword(arguments.password)>
		<cfset setDBType(arguments.dbtype)>
		<cfreturn this>
	</cffunction>

	<cffunction name="setName" access="public" returntype="void">
		<cfargument name="data" type="string" required="false">
		<cfset variables.instance.name = arguments.data>
	</cffunction>

	<cffunction name="setUsername" access="public" returntype="void">
		<cfargument name="data" type="string" required="false">
		<cfset variables.instance.username = arguments.data>
	</cffunction>

	<cffunction name="setPassword" access="public" returntype="void">
		<cfargument name="data" type="string" required="false">
		<cfset variables.instance.password = arguments.data>
	</cffunction>

	<cffunction name="setDBType" access="public" returntype="void">
		<cfargument name="data" type="string" required="false">
		<cfset variables.instance.dbtype = arguments.data>
	</cffunction>

	<cffunction name="getName" access="public" returntype="string">
		<cfreturn variables.instance.name>
	</cffunction>

	<cffunction name="getUsername" access="public" returntype="string">
		<cfreturn variables.instance.username>
	</cffunction>

	<cffunction name="getPassword" access="public" returntype="string">
		<cfreturn variables.instance.password>
	</cffunction>

	<cffunction name="getDBType" access="public" returntype="string">
		<cfreturn variables.instance.dbtype>
	</cffunction>

	<cffunction name="validate" access="public" returntype="boolean">
		<cfreturn (getName() neq "" and getDBType() neq "")>
	</cffunction>

</cfcomponent>