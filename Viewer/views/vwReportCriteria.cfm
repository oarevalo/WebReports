<!--- This shows the report criteria --->
<cfparam name="request.requestState.oReport" default="">
<cfparam name="request.requestState.aSorts" default="">
<cfparam name="request.requestState.aGroups" default="">
<cfparam name="request.requestState.aFilters" default="">

<cfscript>
	oReport = request.requestState.oReport;
	aSorts = request.requestState.aSorts;
	aGroups = request.requestState.aGroups;
	aFilters = request.requestState.aFilters;
</cfscript>

<cfoutput>
	<div style="margin-right:30px;">
		<a href="##" onclick="dialogEvent('ehGroups.dspMain');return false;"><strong>Group By:</strong></a>#arrayToList(aGroups)#
		<cfif arrayLen(aGroups) eq 0><em>None</em></cfif>
		&nbsp;&nbsp;
	
		<a href="##" onclick="dialogEvent('ehSort.dspMain');"><strong>Sort By:</strong></a>#arrayToList(aSorts)#
		<cfif arrayLen(aSorts) eq 0><em>None</em></cfif>
		&nbsp;&nbsp;
	
		<a href="##" onclick="dialogEvent('ehFilters.dspMain');"><strong>Filters:</strong></a>&nbsp;
		<cfif arrayLen(aFilters) gt 0>
			<span style="color:green;font-weight:bold;">Yes</span>
		<cfelse>
			<em>None</em>
		</cfif>			
	</div>
</cfoutput>


