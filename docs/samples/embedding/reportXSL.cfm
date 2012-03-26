<!--- generate XSL document --->
<cfset out = session.oReportRenderer.renderXSL()>

<!---
	Ssend http headers to avoid using a cached version
	of the XSL document.
---->
<cfheader name="Expires" value="#now()#">
<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
<cfheader name="Pragma" value="no-cache">


<!--- Set content type and output content to browser. 
	 Content should follow the cfcontent to avoid generating whitespace --->
<cfcontent type="application/xml"><cfoutput>#out#</cfoutput>
