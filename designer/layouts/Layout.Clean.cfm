<cfsetting showdebugoutput="false">
<cfparam name="request.requestState.viewTemplatePath" default="">

<!--- Render the view --->
<cfif request.requestState.viewTemplatePath neq "">
	<cfinclude template="#request.requestState.viewTemplatePath#">
</cfif>

