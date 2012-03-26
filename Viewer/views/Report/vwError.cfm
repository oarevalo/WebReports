<cfparam name="request.requestState.accessDenied" default="">
<cfset accessDenied = request.requestState.accessDenied>

<!--- This view is only used to display errors --->
<cfinclude template="../../includes/message.cfm">

<cfif isBoolean(accessDenied) and accessDenied>
	<script type="text/javascript">
		setTimeout("window.parent.openDatabasePanel()",500);
	</script>
</cfif>