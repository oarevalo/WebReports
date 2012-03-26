<cfcomponent>
	<cfset this.name = "WebReportsIntegrationSample">
	<cfset this.sessionManagement = true>

	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		<cfset application.currentSessions = structNew()>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="onSessionEnd" returnType="void">
		<cfargument name="sessionScope" required="True" />
		<cfargument name="appScope" required="False" />

		<!--- remove from authenticated sessions registry --->
		<cfif structKeyExists(arguments.appScope, "currentSessions")>
			<cfif structKeyExists(arguments.appScope.currentSessions, arguments.sessionScope.userKey)>
				<cfset structDelete(arguments.appScope.currentSessions, arguments.sessionScope.userKey)>
			</cfif>
		</cfif>
	</cffunction>

</cfcomponent>