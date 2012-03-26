<cfcomponent displayname="Controller" extends="WebReports.Application">
	
	<!--- Application settings --->
	<cfset this.name = "WebReportsPortal"> 

	<!--- Framework settings --->
	<cfset this.defaultEvent = "ehGeneral.dspStart">
	<cfset this.defaultLayout = "Layout.Main">
	<cfset this.appPath = "/WebReports/portal">
	<cfset this.forceRedir = "">

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
