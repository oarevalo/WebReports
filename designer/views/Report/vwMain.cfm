<!--- This view is used to render the report --->
<cfsetting showdebugoutput="no" enablecfoutputonly="yes">

<cfparam name="request.requestState.exportFileName" default="">
<cfparam name="request.requestState.TargetContentType" default="text/xml">
<cfparam name="request.requestState.out" default="">

<!--- get rendering params --->
<cfset exportFileName = request.requestState.exportFileName>
<cfset TargetContentType = request.requestState.TargetContentType>
<cfset out = request.requestState.out>


<!--- If we are exporting to another file type then set the 
		http header to tell the browser to treat the generated
		content as an attachment to prompt user to save/open the file --->
<cfif exportFileName neq "">
	<cfoutput>
		<cfheader name="Content-Disposition" value="attachment;filename=#exportFileName#">
	</cfoutput>
</cfif>


<!--- Set content type and output content to browser. 
	 Content should follow the cfcontent to avoid generating whitespace --->
<cfoutput><cfcontent type="#TargetContentType#">#out#</cfoutput>
