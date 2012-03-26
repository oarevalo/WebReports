<!--- clears an authenticated session --->

<!--- remove from authenticated sessions registry --->
<cfif structKeyExists(application.currentSessions,session.userKey)>
	<cfset structDelete(application.currentSessions, session.userKey)>
</cfif>

<!--- clear session --->
<cfset session.username = "">
<cfset session.userKey = "">
<cfset session.role = "">	
		
<cflocation url="login.cfm" addtoken="false">