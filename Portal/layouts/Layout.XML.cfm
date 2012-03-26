<cfsetting showdebugoutput="false">
<cfparam name="request.requestState.xmlDoc" default="0">
<cfset xmlDoc = request.requestState.xmlDoc>

<cfcontent type="text/xml" reset="true">
<cfoutput><cfif isXMLDoc(xmlDoc)>#toString(xmlDoc)#</cfif></cfoutput>


