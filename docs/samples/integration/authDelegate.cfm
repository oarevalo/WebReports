<!--- sample authentication delegate page --->

<!--- define incoming parameters --->
<cfparam name="reportURL" default="">
<cfparam name="userKey" default="">
<cfparam name="referrer" default="">

<!--- create a new response object --->
<cfset oAuthResponse = createObject("component","WebReports.common.components.authResponse").init()>


<!--- validate report access --->
<cfif structKeyExists(application.currentSessions, userKey)>
	<!--- ok, this user has logged in, now we make sure that the
		user role is authorized to view this report --->
	<cfset stUserSession = application.currentSessions[userKey]>
	
	<!--- for this example, sales people can only view the customer listing report,
		all other reports are only accessible to managers --->
	<cfif getFileFromPath(reportURL) eq "customerListing.xml">
		<cfset isAuthorized = (stUserSession.role eq "sales" or stUserSession.role eq "manager")>
	<cfelse>
		<cfset isAuthorized = (stUserSession.role eq "manager")>
	</cfif>	
<cfelse>
	<!--- we don't who this user is, or is not logged in --->
	<cfset isAuthorized = false>
</cfif>

<!--- populate response object --->
<cfset oAuthResponse.setUserKey(userKey)>
<cfset oAuthResponse.setIsAuthorized(isAuthorized)>
<cfset oAuthResponse.setDatasource("webreportsdemo")>

<!--- construct response --->
<cfset xmlDoc = oAuthResponse.toXML()>

<!--- send response back --->
<cfcontent type="text/xml" reset="true">
<cfoutput>#toString(xmlDoc)#</cfoutput>
