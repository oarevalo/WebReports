<cfcomponent name="layerSuperType">
	
	<cfset variables.instance = structNew()>
	<cfset variables.instance.DAOFactory = 0>

	<cffunction name="init" access="public" hint="constructor" returntype="layerSuperType"> 
		<cfargument name="DAOFactory" type="WebReports.Common.Components.lib.daoFactory.DAOFactory" required="true">
		<cfset setDAOFactory(arguments.DAOFactory)>
		<cfreturn this>
	</cffunction>

	<cffunction name="setDAOFactory" access="public" returntype="void">
		<cfargument name="DAOFactory" type="WebReports.Common.Components.lib.daoFactory.DAOFactory" required="true">
		<cfset variables.instance.DAOFactory = arguments.DAOFactory>
	</cffunction>

	<cffunction name="getDAOFactory" access="public" returntype="WebReports.Common.Components.lib.daoFactory.DAOFactory">
		<cfreturn variables.instance.DAOFactory>
	</cffunction>
	
	<cffunction name="throw" access="private" hint="Facade for cfthrow">
		<cfargument name="message" 		type="String" required="yes">
		<cfargument name="type" 		type="String" required="no" default="custom">
		<cfthrow type="#arguments.type#" message="#arguments.message#">
	</cffunction>
	
	<cffunction name="dump" access="private" hint="Facade for cfmx dump">
		<cfargument name="var" required="yes">
		<cfdump var="#var#">
	</cffunction>
	
	<cffunction name="abort" access="private" hint="Facade for cfabort">
		<cfabort>
	</cffunction>
	
</cfcomponent>