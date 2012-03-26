<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfscript>
	// This is the URL for the XSL document that will
	// transform the data into the report
	xslHREF = "reportXSL.cfm";

	// generate output
	out = session.oReportRenderer.renderXML(xslHREF);
</cfscript>
<cfcontent type="text/xml" reset="true">
<cfoutput>#out#</cfoutput>

