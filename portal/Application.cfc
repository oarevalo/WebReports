<cfcomponent extends="WebReports.common.components.Application">
	
	<!--- Application settings --->
	<cfset this.name = "WebReportsPortal"> 

	<!--- Framework Settings --->
	<cfset this.paths.app = "/WebReports/portal/">
	<cfset this.defaultEvent = "ehGeneral.dspStart">

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
