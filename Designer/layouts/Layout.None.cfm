<cfsetting showdebugoutput="false">

<cfparam name="request.requestState.viewTemplatePath" default="">
<cfparam name="request.requestState.refreshReport" default="false">
<cfparam name="request.requestState.refreshPods" default="false">

<!--- Display any system messages sent from the event hander --->
<cfinclude template="../includes/message.cfm">

<!--- Render the view --->
<cfif request.requestState.viewTemplatePath neq "">
	<cfinclude template="#request.requestState.viewTemplatePath#">
</cfif>

<!--- handle the refrehReport flag --->
<cfif request.requestState.refreshReport>
	<script>
		loadReport();
	</script>
</cfif>

<cfif request.requestState.refreshPods>
	<script>
		loadPods();
	</script>
</cfif>