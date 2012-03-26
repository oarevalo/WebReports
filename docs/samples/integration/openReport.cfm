<!--- do a very basic check to see if the user has logged in --->
<cfif not StructKeyExists(session,"username") or session.username  eq "">
	<cflocation url="login.cfm" addtoken="false">
</cfif>

<cfparam name="report" default="">

<cfset viewerURL = "/WebReports/Viewer/index.cfm">
<cfset reportURL = "/WebReports/docs/samples/integration/reports/" & report>
<cfset exitURL = "/WebReports/docs/samples/integration">

<!--- redirect to report viewer --->
<cflocation url="#viewerURL#?report=#reportURL#&userKey=#session.userKey#&exitURL=#exitURL#" addtoken="false">