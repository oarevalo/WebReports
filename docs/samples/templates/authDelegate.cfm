<!--- This is a template for an authentication delegate page --->

<!--- define incoming parameters --->
<cfparam name="reportURL" default="">	<!--- URL of report that users wants to access --->
<cfparam name="userKey" default="">		<!--- a key that identifies the user (passed into the report viewer when opening the report) --->
<cfparam name="referrer" default="">	<!--- the page from which they tried to access the report --->


<!--- create a new response object --->
<cfset oAuthResponse = createObject("component","WebReports.common.components.authResponse").init()>


<!--- /// ... here goes the logic that checks whether we should allow the user to 
	view the report .... //// --->
<cfset isAuthorized = true>
<!--- /// ...  //// --->


<!--- populate response object --->
<cfset oAuthResponse.setUserKey(userKey)>
<cfset oAuthResponse.setIsAuthorized(isAuthorized)>


<!--- construct response --->
<cfset xmlDoc = oAuthResponse.toXML()>


<!--- send response back --->
<cfcontent type="text/xml" reset="true">
<cfoutput>#toString(xmlDoc)#</cfoutput>
